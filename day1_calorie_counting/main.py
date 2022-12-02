d = [sum(map(int,x.split())) for x in open("input","rt").read().strip().split("\n\n")]
print(max(d),sum(sorted(d)[-3:]))
