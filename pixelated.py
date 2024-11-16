import sys
import fitz  # PyMuPDF
from typing import List
import numpy as np
from PIL import Image
from io import BytesIO
Image.MAX_IMAGE_PIXELS = None


class Sequence:
    def __init__(self, start, end, length, contents, white):
        self.start, self.end, self.length, self.white = start, end, length, white
        self._contents = contents
        self.delta = 0

    def set_new_length(self, length):
        if not self.white:
            raise ValueError("Wanted to decrease size of text")
        self.delta += length - self.length
        self.length = length
        self._contents = 255 + np.zeros((int(self.length), self._contents.shape[1], 3))


class PageWrapper:
    def __init__(self, page_num: int, document: fitz.Document):
        # get data as array
        self.page = document.load_page(page_num)

        pix = self.page.get_pixmap(colorspace=fitz.csRGB, dpi=180)
        img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
        self.array = np.array(img)
        white_pixels = np.all(self.array >= np.array([250, 250, 250]), axis=2)
        self.white_rows = np.all(white_pixels, axis=1)  # Shape (height,)
        self.sequences = None

    def get_sequences(self) -> List[Sequence]:
        if self.sequences is not None:
            return self.sequences
        current_value = False
        start = 0
        length = 1
        results = []
        print(f"white Rows {self.white_rows.shape}")
        for i, row in enumerate(self.white_rows.tolist()):
            if row == current_value:
                length += 1
                continue
            results.append(Sequence(start, i, length, white=current_value, contents=self.array[start:i, :, :]))
            current_value = row
            start = i
            length = 1
        self.sequences = results
        return results


def process_pdf(pdf_path):
    try:
        # Open the PDF document
        doc = fitz.open(pdf_path)
    except Exception as e:
        print(f"Error opening PDF file: {e}")
        sys.exit(1)

    new_doc = fitz.open()  # New PDF document

    for page_num in range(len(doc)):
        bin_count = 10
        page = PageWrapper(page_num, doc)
        sequences = page.get_sequences()
        print(sequences)

        lengths_to_approx = np.array([seq.length for seq in sequences if seq.white])
        hist, bin_edges = np.histogram(lengths_to_approx, bins=bin_count)
        sorted_values = sorted([(hist, bin) for hist, bin in zip(hist, bin_edges)], key=lambda x: x[1], reverse=True)
        cluster_centers = [edge for _, edge in sorted_values][-2:]
        cluster_centers = np.sort(cluster_centers)
        print("\n".join([f"{h}: {e}" for h, e in zip(hist, bin_edges)]))

        # Reduce lengths of sequences shorter than average by half
        for seq in sequences:
            if not seq.white:
                continue
            if seq.length <= cluster_centers[0]:
                seq.set_new_length(max(1, seq.length // 5))
            elif seq.length >= cluster_centers[1]:
                seq.set_new_length(1)

        total_removed_rows = sum(- seq.delta for seq in sequences if seq.delta < 0)
        print(f"total_removed_rows {total_removed_rows}")
        num_to_add_to = len([seq for seq in sequences if seq.delta == 0 and seq.white])
        print(f"num_to_add_to {num_to_add_to} {total_removed_rows // num_to_add_to}")

        if num_to_add_to != 0 and total_removed_rows != 0:
            for seq in sequences:
                if seq.delta < 0 or not seq.white:
                    continue

                seq.set_new_length(seq.length + total_removed_rows // num_to_add_to)

        new_img_np = []
        for seq in sequences:
            for row in seq._contents.tolist():
                new_img_np.append(np.array(row))

        new_img_np = np.array(new_img_np)
        print(f"FINAL: {new_img_np.shape}")
        new_img_np = np.append(new_img_np, 255 + np.zeros((page.array.shape[0] - new_img_np.shape[0], new_img_np.shape[1], 3)), axis=0)
        print(f"FINAL: {new_img_np.shape}")
        new_img = Image.fromarray(new_img_np.astype('uint8'), mode='RGB')

        # Save the image to a bytes buffer
        img_buffer = BytesIO()
        new_img.save(img_buffer, format='PNG')
        img_buffer.seek(0)

        # Create a new page in the new PDF document with the same dimensions
        page_width = page.page.rect.width
        page_height = page.page.rect.height
        new_page = new_doc.new_page(width=page_width, height=page_height)

        # Insert the image into the new page
        new_page.insert_image(fitz.Rect(0, 0, page_width, page_height), stream=img_buffer.getvalue())

    # Save the new PDF
    output_pdf = pdf_path[:-4] + "_RESHAPE.pdf"
    new_doc.save(output_pdf)
    print(f"Processed PDF saved as '{output_pdf}'")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py your_file.pdf")
        pdf_path = "/home/admin/projects/small/NumSDE2021_Skript.pdf"
    else:
        pdf_path = sys.argv[1]
    process_pdf(pdf_path)
