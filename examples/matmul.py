import numpy as np
import sys

N = int(sys.argv[1]) #mats size from command line

A = np.random.rand(N,N)
B = np.random.rand(N,N)

print(np.linalg.norm(A @ B))
