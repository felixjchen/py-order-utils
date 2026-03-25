#!/bin/bash
set -e

echo "=== py_order_utils Publishing Script ==="

DRY_RUN=false
BUMP_VERSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --bump)
            BUMP_VERSION="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: ./publish.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run      Build but don't upload to PyPI"
            echo "  --bump TYPE    Bump version (e.g. 0.3.3)"
            echo "  -h, --help     Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

CURRENT_VERSION=$(python3 -c "import re; print(re.search(r'version=\"(.+?)\"', open('setup.py').read()).group(1))")
echo "Current version: ${CURRENT_VERSION}"

if [ -n "$BUMP_VERSION" ]; then
    sed -i '' "s/version=\"${CURRENT_VERSION}\"/version=\"${BUMP_VERSION}\"/" setup.py
    echo "New version: ${BUMP_VERSION}"
fi

if [ -n "$(git status --porcelain)" ]; then
    echo "Warning: You have uncommitted changes"
    git status --short
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Cleaning previous builds..."
rm -rf dist/ build/ *.egg-info

echo "Building package..."
python3 -m build

echo "Built packages:"
ls -la dist/

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

if [ "$DRY_RUN" = true ]; then
    echo "Dry run mode - skipping upload to PyPI"
    echo "To publish manually, run:"
    echo "  python3 -m twine upload dist/*"
else
    echo "Publishing to PyPI..."

    if [ -n "$PYPI_TOKEN" ]; then
        echo "Using PYPI_TOKEN from environment"
        python3 -m twine upload dist/* --username __token__ --password "$PYPI_TOKEN"
    else
        echo "No PYPI_TOKEN found. You will be prompted for credentials."
        python3 -m twine upload dist/*
    fi

    FINAL_VERSION=$(python3 -c "import re; print(re.search(r'version=\"(.+?)\"', open('setup.py').read()).group(1))")
    echo "Successfully published py_order_utils ${FINAL_VERSION} to PyPI!"
    echo "View at: https://pypi.org/project/py_order_utils/${FINAL_VERSION}/"
fi

echo "Done!"
