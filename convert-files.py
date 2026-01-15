# Import things to make run
from subprocess import run
from pathlib import Path
import argparse

# Set up argparse so it isn't stupid
parser = argparse.ArgumentParser(
    description="A script to convert markdown to different formats"
)

parser.add_argument(
    "input", type=str, default="ccdc-bible.md", help="Path to input file"
)
parser.add_argument(
    "output", type=str, default="ccdc-bible.pdf", help="Path to output file"
)
parser.add_argument(
    "--markdown_to_tex",
    type=bool,
    default=False,
    help="Convert markdown to tex file",
)
parser.add_argument("--tex_to_pdf", type=bool, default=False, help="convert tex to pdf")
parser.add_argument(
    "--markdown_to_pdf", type=bool, default=True, help="Convert markdown to pdf"
)
parser.add_argument("--landscape", type=bool, default=False, help="Build landscape pdf")


args = parser.parse_args()

# Set files
input_file_path = Path(args.input)
output_file_path = Path(args.output)
buildinfo_file_path = Path("build/buildinfo.tex")
template_file_path = Path("md-to-tex.latex")
tipbox_file_path = Path("build/tipbox.lua")

if args.landscape:
    metadata_file_path = Path("build/landscape-meta.yaml")
    preamble_file_path = Path("build/landscape-preamble.tex")
else:
    metadata_file_path = Path("build/meta.yaml")
    preamble_file_path = Path("build/preamble.tex")

if args.markdown_to_tex:
    operation = "md_to_tex"
elif args.tex_to_pdf:
    operation = "tex_to_pdf"
else:
    operation = "md_to_pdf"


# Function bc who knows how this will change
def md_to_pdf(old_file, new_file):
    run(
        [
            "pandoc",
            f"{old_file}",
            f"--metadata-file={metadata_file_path}",
            f"--include-in-header={preamble_file_path}",
            f"--include-in-header={buildinfo_file_path}",
            f"--lua-filter={tipbox_file_path}",
            "--toc",
            "--pdf-engine=xelatex",
            "--listings",
            "-o",
            f"{new_file}",
        ]
    )


def md_to_tex(old_file, new_file):
    run(
        [
            "pandoc",
            f"{old_file}",
            f"--metadata-file={metadata_file_path}",
            f"--lua-filter={tipbox_file_path}",
            "--pdf-engine=xelatex",
            "--listings",
            "--standalone",
            "--to=latex",
            f"--template={template_file_path}",
            "-o",
            f"{new_file}",
        ]
    )


def tex_to_pdf(old_file):
    for i in range(2):
        run(["xelatex", f"{old_file}"])


match operation:
    case "md_to_tex":
        md_to_tex(input_file_path, output_file_path)
    case "tex_to_pdf":
        tex_to_pdf(input_file_path)
    case "md_to_pdf":
        md_to_pdf(input_file_path, output_file_path)
