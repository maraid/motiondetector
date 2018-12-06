from tinyos import tos

color = lambda edge: '\033[1;31m' if edge == 1 else '\033[1;32m'
am = tos.AM()
shape = "\033[H\033[J  0  \n {}/ {}\\\033[0m \n0{}---\033[0m0"
while True:
    payload = am.read().data[0] 
    print(shape.format(*[color(payload >> n & 1) for n in range(3)]))
