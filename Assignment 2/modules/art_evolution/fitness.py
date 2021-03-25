from skimage.metrics import structural_similarity
import numpy as np


def fitness_function(original_image, candidate):
    # check the similarity index of the original and candidate image
    candidate = np.asarray(candidate.convert('RGB'), dtype=np.int32)
    score_candidate = structural_similarity(original_image, candidate,
                                            data_range=original_image.max() - candidate.min(),
                                            multichannel=True)
    return score_candidate
