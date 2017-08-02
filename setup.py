from setuptools import setup, find_packages
from setuptools.command.develop import develop as DevelopCommand

setup(
    name='cloud',
    version='0.0.1',
    packages=find_packages(),
    include_package_data=True,
    cmdclass={
        'develop': DevelopCommand
    },
    install_requires=[
        'Click',
    ],
    entry_points={
        'console_scripts': [
            'cloud=lib.cli:cli',
        ],
    }
)
