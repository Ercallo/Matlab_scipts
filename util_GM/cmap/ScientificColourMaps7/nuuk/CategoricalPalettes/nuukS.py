# 
#         nuukS
#                   www.fabiocrameri.ch/colourmaps
from matplotlib.colors import LinearSegmentedColormap      
      
cm_data = [[0.018013, 0.35076, 0.55062],      
           [0.99624, 0.99617, 0.69898],      
           [0.62687, 0.64679, 0.59496],      
           [0.76407, 0.76242, 0.52329],      
           [0.32627, 0.46592, 0.52129],      
           [0.70881, 0.70953, 0.56877],      
           [0.86151, 0.86045, 0.54089],      
           [0.17746, 0.39178, 0.51305],      
           [0.49153, 0.56138, 0.56991],      
           [0.40922, 0.51298, 0.54421],      
           [0.80219, 0.80083, 0.51446],      
           [0.11153, 0.36847, 0.52866],      
           [0.67452, 0.68126, 0.58716],      
           [0.9331, 0.9322, 0.61078],      
           [0.73625, 0.73494, 0.54537],      
           [0.24784, 0.42427, 0.50965],      
           [0.563, 0.60509, 0.58822],      
           [0.59688, 0.62677, 0.59348],      
           [0.14469, 0.37915, 0.51968],      
           [0.65268, 0.66494, 0.59273],      
           [0.7496, 0.748, 0.53363],      
           [0.96608, 0.96546, 0.65418],      
           [0.28617, 0.44415, 0.51367],      
           [0.45078, 0.53722, 0.55732],      
           [0.3675, 0.48906, 0.53182],      
           [0.69296, 0.696, 0.57894],      
           [0.21161, 0.40677, 0.50952],      
           [0.073701, 0.35918, 0.5392],      
           [0.78104, 0.7795, 0.51602],      
           [0.89743, 0.89642, 0.5716],      
           [0.829, 0.82782, 0.52184],      
           [0.72295, 0.72233, 0.55735],      
           [0.53069, 0.58508, 0.58085],      
           [0.9155, 0.91453, 0.5904],      
           [0.68411, 0.68881, 0.58334],      
           [0.84463, 0.84352, 0.52983],      
           [0.4713, 0.54933, 0.56376],      
           [0.70115, 0.70289, 0.57405],      
           [0.093625, 0.36368, 0.53377],      
           [0.94999, 0.9492, 0.63218],      
           [0.71604, 0.716, 0.56318],      
           [0.16097, 0.38519, 0.51602],      
           [0.74286, 0.74135, 0.53941],      
           [0.43006, 0.52509, 0.55075],      
           [0.12832, 0.3736, 0.52393],      
           [0.30607, 0.45484, 0.51707],      
           [0.3468, 0.47736, 0.52626],      
           [0.26676, 0.43393, 0.51118],      
           [0.77215, 0.77053, 0.51913],      
           [0.79099, 0.78953, 0.51434],      
           [0.6403, 0.65611, 0.59429],      
           [0.66407, 0.67332, 0.59031],      
           [0.72965, 0.72862, 0.55138],      
           [0.98144, 0.98106, 0.67651],      
           [0.61239, 0.637, 0.5947],      
           [0.58039, 0.61612, 0.59131],      
           [0.87927, 0.87824, 0.55492],      
           [0.38834, 0.50096, 0.53786],      
           [0.22943, 0.41521, 0.50911],      
           [0.81483, 0.81357, 0.51683],      
           [0.19431, 0.39896, 0.51085],      
           [0.75662, 0.75497, 0.5282],      
           [0.049338, 0.35491, 0.54484],      
           [0.51135, 0.57331, 0.57566],      
           [0.5448, 0.59375, 0.5843],      
           [0.67941, 0.68509, 0.58534],      
           [0.58874, 0.62149, 0.59252],      
           [0.55399, 0.59946, 0.58637],      
           [0.78587, 0.78437, 0.51498],      
           [0.72632, 0.72548, 0.55437],      
           [0.73296, 0.73177, 0.54838],      
           [0.20287, 0.40279, 0.51007],      
           [0.52109, 0.57922, 0.57833],      
           [0.63372, 0.65151, 0.59474],      
           [0.44043, 0.53115, 0.55404],      
           [0.61977, 0.64195, 0.59495],      
           [0.37791, 0.49499, 0.53478],      
           [0.80833, 0.80702, 0.51533],      
           [0.46106, 0.54328, 0.56056],      
           [0.76028, 0.75863, 0.52567],      
           [0.64662, 0.66058, 0.59361],      
           [0.77648, 0.77489, 0.51743],      
           [0.95813, 0.95742, 0.64313],      
           [0.6585, 0.66919, 0.59162],      
           [0.9065, 0.90551, 0.58077],      
           [0.22047, 0.41091, 0.50919],      
           [0.87031, 0.86927, 0.54755],      
           [0.10277, 0.36604, 0.53117],      
           [0.5015, 0.56736, 0.57285],      
           [0.033826, 0.35281, 0.54772],      
           [0.82173, 0.8205, 0.51899],      
           [0.18583, 0.3953, 0.51185],      
           [0.16919, 0.38842, 0.51445],      
           [0.25723, 0.42904, 0.51029],      
           [0.74621, 0.74464, 0.5365],      
           [0.29607, 0.44943, 0.51526],      
           [0.35714, 0.48318, 0.52897],      
           [0.79642, 0.79501, 0.51415],      
           [0.68862, 0.69245, 0.58121],      
           [0.94164, 0.94079, 0.62138]]      
      
nuukS_map = LinearSegmentedColormap.from_list('nuukS', cm_data)      
# For use of "viscm view"      
test_cm = nuukS_map      
      
if __name__ == "__main__":      
    import matplotlib.pyplot as plt      
    import numpy as np      
      
    try:      
        from viscm import viscm      
        viscm(nuukS_map)      
    except ImportError:      
        print("viscm not found, falling back on simple display")      
        plt.imshow(np.linspace(0, 100, 256)[None, :], aspect='auto',      
                   cmap=nuukS_map)      
    plt.show()      
