import json, os, sys
root = sys.argv[1]
def color(h):
    return "srgb:%.8f,%.8f,%.8f,1.00000000" % tuple(int(h[i:i+2], 16) / 255 for i in (1, 3, 5))
def svg(body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">{body}</svg>'
def layer(name, light, dark):
    return {"glass": True, "hidden": False, "image-name": f"{name}.svg", "name": name, "opacity": 1,
            "position": {"scale": 1, "translation-in-points": [0, 0]},
            "fill-specializations": [{"value": {"solid": color(light)}}, {"appearance": "dark", "value": {"solid": color(dark)}}]}
def write(name, layers, assets):
    folder = os.path.join(root, f"{name}.icon"); os.makedirs(os.path.join(folder, "Assets"), exist_ok=True)
    for file, body in assets.items():
        open(os.path.join(folder, "Assets", f"{file}.svg"), "w").write(svg(body))
    background = [{"value": {"automatic-gradient": color("#22C55E")}}, {"appearance": "dark", "value": "system-dark"}]
    json.dump({"fill-specializations": background, "groups": [{"layers": layers,
        "shadow": {"kind": "layer-color", "opacity": 0.5}, "translucency": {"enabled": True, "value": 0.3},
        "specular": True, "lighting": "combined"}], "supported-platforms": {"squares": "shared"}},
        open(os.path.join(folder, "icon.json"), "w"), indent=2)
W = "#FFFFFF"
EXIT = (716, 308)
gap = f'<mask id="g"><rect width="1024" height="1024" fill="white"/><circle cx="{EXIT[0]}" cy="{EXIT[1]}" r="150" fill="black"/></mask>'
exit_disc = f'<circle cx="{EXIT[0]}" cy="{EXIT[1]}" r="100" fill="{W}"/>'
# G2. Larger, no disc inside: the open room, the trail, the disc leaving.
EX, EY, ER = 800, 224, 132
gap2 = f'<mask id="g"><rect width="1024" height="1024" fill="white"/><circle cx="{EX}" cy="{EY}" r="196" fill="black"/></mask>'
frame2 = (gap2 + f'<path mask="url(#g)" fill-rule="evenodd" fill="{W}" d="M 342 172 H 682 A 170 170 0 0 1 852 342 V 682 A 170 170 0 0 1 682 852 H 342 A 170 170 0 0 1 172 682 V 342 A 170 170 0 0 1 342 172 Z '
          'M 344 282 H 680 A 62 62 0 0 1 742 344 V 680 A 62 62 0 0 1 680 742 H 344 A 62 62 0 0 1 282 680 V 344 A 62 62 0 0 1 344 282 Z"/>')
trail = ''.join(f'<circle cx="{x}" cy="{y}" r="{r}" fill="{W}"/>' for x, y, r in [(636, 388, 50), (536, 488, 38), (448, 576, 28)])
leaving = f'<circle cx="{EX}" cy="{EY}" r="{ER}" fill="{W}"/>'
write("G2", [layer("exit", W, "#BBF7D0"), layer("dots", "#BBF7D0", "#86EFAC"), layer("frame", W, "#22C55E")],
      {"frame": frame2, "dots": trail, "exit": leaving})
print("ok")
