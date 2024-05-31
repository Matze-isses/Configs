from distutils.core import setup
from setuptools import find_packages

setup(
    name="hypr_handler",
    description="Handles some stuff relating to Hyprland",
    version="0.1",
    packages=find_packages(),
    package_data={
        "": ['config/*.yml']
    },
    include_package_data=True,
    install_requires=["hyprland"]
)
