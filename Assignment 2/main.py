from modules.art_evolution.evolution import run_evolution

if __name__ == "__main__":
    # run evolutionary algorithm
    result = run_evolution()
    # save the produced image
    result.save('/documents/output/result.png')
