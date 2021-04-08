from modules.art_evolution.evolution import run_evolution
from config import FILE_NAME

if __name__ == "__main__":
    # run evolutionary algorithm
    # set parameter use_palette to False for using entire color space
    # otherwise, go to config.py and follow the instructions
    result = run_evolution(use_palette=True)
    # save the produced image
    result.save(f'/documents/output/{FILE_NAME}/result.jpeg')
