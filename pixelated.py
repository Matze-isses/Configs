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
    bin_count = 50
    lengths_to_approx = []

    for page_num in range(len(doc)):
        page = PageWrapper(page_num, doc)
        sequences = page.get_sequences()
        lengths_to_approx += [seq.length for seq in sequences if not seq.white]

    hist, bin_edges = np.histogram(lengths_to_approx, bins=bin_count)
    hist = np.array(hist) / max(hist)
    most_often = -1
    cap_above = -1

    for i, item in enumerate(hist):
        if item == 1 and most_often < 0:
            most_often = bin_edges[i+1]
        if most_often > 0 and item > 0.4 and cap_above < 0 and most_often < bin_edges[i]:
            cap_above = bin_edges[i]

    for page_num in range(len(doc)):
        page = PageWrapper(page_num, doc)
        sequences = page.get_sequences()

        last_black_length = 0
        for seq in sequences:
            if not seq.white:
                last_black_length = seq.length
                continue

            if last_black_length <= most_often or cap_above < most_often:
                seq.set_new_length(3)
                last_black_length = 0

        total_removed_rows = sum(- seq.delta for seq in sequences)
        print(f"total_removed_rows {total_removed_rows}")
        num_to_add_to = len([seq for seq in sequences if seq.delta >= 0 and seq.white])

        if num_to_add_to != 0 and total_removed_rows != 0:
            leftover = total_removed_rows - int(total_removed_rows / num_to_add_to)
            portions = 12
            print(f"LEFTOVER: {leftover}")

            for seq in sequences:
                if seq.delta < 0 or not seq.white:
                    continue

                seq.set_new_length(seq.length + int(total_removed_rows / num_to_add_to))
                if leftover >= portions:
                    seq.set_new_length(seq.length + portions)
                    leftover -= portions

            print(f"num_to_add_to {num_to_add_to} {int(total_removed_rows / num_to_add_to)}")

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
