from modules.art_evolution.evolution import run_evolution
from config import FILE_NAME

if __name__ == "__main__":
    # run evolutionary algorithm
    result = run_evolution()
    # save the produced image
    result.save(f'/documents/output/{FILE_NAME}/result.jpeg')
