# -*- coding: utf-8 -*-
"""Generate the 60 traditional Chinese colors dataset (JSON + CSV) and a palette preview PNG."""
import json, csv, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, "data")
os.makedirs(DATA, exist_ok=True)

FAMILIES = [
    {"id": "red",     "zh": "红系",   "en": "Red"},
    {"id": "ochre",   "zh": "橙赭系", "en": "Ochre"},
    {"id": "yellow",  "zh": "黄系",   "en": "Yellow"},
    {"id": "green",   "zh": "绿系",   "en": "Green"},
    {"id": "blue",    "zh": "青蓝系", "en": "Blue"},
    {"id": "purple",  "zh": "紫系",   "en": "Purple"},
    {"id": "neutral", "zh": "白灰黑系","en": "Neutral"},
    {"id": "earth",   "zh": "褐土系", "en": "Earth"},
]

# id, family, 中文名, pinyin, English name, HEX, noteEn, noteZh
C = [
    # ---- Red 红系 ----
    ("zhusha","red","朱砂","zhū shā","Cinnabar","#E63E21","Mineral red ground from cinnabar ore, the color of seals and lacquerware.","矿物颜料，印章与漆器之红。"),
    ("yanzhi","red","胭脂","yān zhi","Rouge Red","#9D2933","Deep red of traditional rouge made from safflower petals.","红花制成的妆粉，深而柔的红。"),
    ("qianse","red","茜色","qiàn sè","Madder","#B03A2E","Warm plant red dyed from madder root.","茜草根染出的暖红。"),
    ("jianghong","red","绛红","jiàng hóng","Deep Crimson","#8C2F39","Solemn crimson once worn in ceremonial robes.","礼服常用的大红，沉稳庄重。"),
    ("feihong","red","绯红","fēi hóng","Scarlet","#C83C23","Bright scarlet of Tang-dynasty officials' dress.","唐代官服之色，鲜亮夺目。"),
    ("haitanghong","red","海棠红","hǎi táng hóng","Crabapple Red","#DB5A6B","Soft blossom red of flowering crabapple.","春日海棠花的柔红。"),
    ("shiliuhong","red","石榴红","shí liu hóng","Pomegranate Red","#EE2E16","Vivid, festive red of pomegranate blossom.","石榴花开，热烈喜庆。"),
    ("taohong","red","桃红","táo hóng","Peach Pink","#F47983","Tender pink of newly opened peach blossom.","桃花初绽的嫩粉。"),
    ("feise","red","妃色","fēi sè","Consort Pink","#ED5736","Warm pink-red once favored in court dress.","古时常用于妃嫔服饰的暖红。"),
    ("huohong","red","火红","huǒ hóng","Flame Red","#EA2E2E","Hot, glowing red of an open flame.","如火焰般炽热的红。"),
    ("zaohong","red","枣红","zǎo hóng","Jujube Red","#7C1823","Deep, mellow red of ripe jujube dates.","红枣成熟后的深沉红。"),
    ("yinhong","red","银红","yín hóng","Silver Red","#F05654","Light red brightened with a silvery sheen.","掺了银粉的浅红，带光泽。"),
    # ---- Ochre 橙赭系 ----
    ("zheshi","ochre","赭石","zhě shí","Red Ochre","#9E4A2E","Iron-oxide earth pigment, among the oldest painting colors.","最古老的土色颜料之一。"),
    ("juhong","ochre","橘红","jú hóng","Tangerine","#FF7500","Bright orange of ripe tangerine peel.","橘皮般的亮橙红。"),
    ("chenghuang","ochre","橙黄","chéng huáng","Orange Gold","#FFA400","Warm orange resting between yellow and red.","介于黄与橙之间的暖色。"),
    ("hupo","ochre","琥珀","hǔ pò","Amber","#CA6924","Translucent golden brown of fossilized resin.","树脂化石的通透金棕。"),
    ("chase","ochre","茶色","chá sè","Tea Brown","#A97844","Warm brown of a strong cup of steeped tea.","浓茶一般的暖棕。"),
    # ---- Yellow 黄系 ----
    ("minghuang","yellow","明黄","míng huáng","Imperial Yellow","#FFC90E","Brilliant yellow once reserved for the emperor.","帝王专用的亮黄。"),
    ("ehuang","yellow","鹅黄","é huáng","Gosling Yellow","#FFF143","Soft light yellow of a gosling's down.","雏鹅绒毛般的嫩黄。"),
    ("xinghuang","yellow","杏黄","xìng huáng","Apricot Yellow","#FFA631","Mellow yellow of ripening apricots.","杏子成熟时的暖黄。"),
    ("jianghuang","yellow","姜黄","jiāng huáng","Ginger Yellow","#FFC773","Warm yellow of fresh ginger root.","生姜根茎的温黄色。"),
    ("tenghuang","yellow","藤黄","téng huáng","Gamboge","#FFB61E","Classic resin yellow of traditional ink painting.","传统国画常用的树脂黄。"),
    ("qiuxiangse","yellow","秋香色","qiū xiāng sè","Autumn Fragrance","#D9B611","Muted gold-green of leaves in early autumn.","初秋树叶的黄绿之间。"),
    ("xiangse","yellow","缃色","xiāng sè","Silk Yellow","#F0C239","Pale yellow of fine silk gauze.","浅黄色丝帛之色。"),
    ("xionghuang","yellow","雄黄","xióng huáng","Realgar","#E98B2A","Orange-yellow of the mineral realgar.","矿物雄黄的橙黄色。"),
    # ---- Green 绿系 ----
    ("songhualv","green","松花绿","sōng huā lǜ","Pine Green","#057748","Deep green touched with pine-pollen warmth.","松花粉般的深绿。"),
    ("zhuqing","green","竹青","zhú qīng","Bamboo Green","#789262","Greyish green of bamboo skin.","竹皮外层的灰绿。"),
    ("liulv","green","柳绿","liǔ lǜ","Willow Green","#AFDD22","Fresh yellow-green of new willow leaves.","新柳嫩芽的黄绿。"),
    ("doulv","green","豆绿","dòu lǜ","Pea Green","#9ED048","Soft green of young pea pods.","青豆荚的柔绿。"),
    ("ailv","green","艾绿","ài lǜ","Mugwort Green","#92A878","Dusty, quiet green of mugwort leaves.","艾叶的灰调绿。"),
    ("shilv","green","石绿","shí lǜ","Malachite Green","#16A951","Mineral green ground from malachite, layered in murals.","孔雀石研磨的矿物绿。"),
    ("bise","green","碧色","bì sè","Jade Green","#2EDFA3","Clear, translucent green of fine jade.","美玉般清透的绿。"),
    ("conglv","green","葱绿","cōng lǜ","Scallion Green","#40DE5A","Vivid green of fresh scallions.","青葱般鲜亮的绿。"),
    ("youlv","green","油绿","yóu lǜ","Glossy Green","#00BC12","Deep, lustrous green like oil on leaves.","叶面油光般的深绿。"),
    # ---- Blue 青蓝系 ----
    ("tianqing","blue","天青","tiān qīng","Sky After Rain","#9EC7C9","The fabled Ru-ware glaze: the sky's blue after rain clears.","雨过天青云破处的汝窑色。"),
    ("yuebai","blue","月白","yuè bái","Moonlight White","#D6ECF0","Pale blue-white of silk under moonlight.","月下素绢的淡蓝白。"),
    ("daise","blue","黛色","dài sè","Eyebrow Indigo","#4A4E69","Deep blue-black once used to paint eyebrows.","古时画眉的青黑色。"),
    ("dianqing","blue","靛青","diàn qīng","Indigo","#177CB0","Plant indigo of traditional blue-dyed cloth.","蓝草染布的靛蓝。"),
    ("qunqing","blue","群青","qún qīng","Ultramarine Ash","#4C8DAE","Mineral blue of blue-and-green landscape painting.","青绿山水常用的矿蓝。"),
    ("baolan","blue","宝蓝","bǎo lán","Sapphire Blue","#4B5CC4","Brilliant jewel blue of sapphires.","蓝宝石般的亮蓝。"),
    ("zangqing","blue","藏青","zàng qīng","Deep Navy","#2E4E7E","Deep, steady navy used in robes and workwear.","深邃沉稳的藏蓝。"),
    ("shiqing","blue","石青","shí qīng","Azurite Blue","#1685A9","Mineral blue ground from azurite, paired with malachite.","蓝铜矿研磨的矿物蓝。"),
    ("hulan","blue","湖蓝","hú lán","Lake Blue","#2CB5C9","Clear, bright blue of calm lake water.","湖水般明净的蓝。"),
    ("jilan","blue","霁蓝","jì lán","Clearing-Sky Blue","#2C4A7C","Deep sacrificial blue of Ming-dynasty porcelain.","明代霁蓝釉瓷的深蓝。"),
    # ---- Purple 紫系 ----
    ("zitan","purple","紫檀","zǐ tán","Rosewood","#4C221B","Dark purple-brown of precious rosewood.","紫檀木的紫褐。"),
    ("ouhese","purple","藕荷色","ǒu hé sè","Lotus-Root Mauve","#E4C6D0","Pale mauve-pink of fresh lotus root.","莲藕般的浅紫粉。"),
    ("dingxiangse","purple","丁香色","dīng xiāng sè","Lilac","#CCA4E3","Light purple of lilac blossom.","丁香花的淡紫。"),
    ("qinglian","purple","青莲","qīng lián","Blue Lotus","#8B66A9","Blue-purple of the lotus in Buddhist art.","佛教青莲花的蓝紫。"),
    ("ziteng","purple","紫藤","zǐ téng","Wisteria","#8A79AF","Soft purple of hanging wisteria flowers.","紫藤花垂落的柔紫。"),
    ("xueqing","purple","雪青","xuě qīng","Snow Violet","#B0A4E3","Cool violet, like snow under evening light.","雪光映出的冷紫。"),
    # ---- Neutral 白灰黑系 ----
    ("xiangyabai","neutral","象牙白","xiàng yá bái","Ivory","#FFFBF0","Warm, creamy white of ivory.","象牙温润的乳白。"),
    ("mibai","neutral","米白","mǐ bái","Rice White","#F5F1E8","Gentle off-white of polished rice.","新米般的柔白。"),
    ("shuangse","neutral","霜色","shuāng sè","Frost White","#E9F1F6","Cold white-grey of morning frost.","晨霜覆地的冷白。"),
    ("qianhui","neutral","铅灰","qiān huī","Lead Grey","#7B7F87","Cool, steady grey of lead.","铅灰色的沉静。"),
    ("canghui","neutral","苍灰","cāng huī","Ash Grey","#91989F","Pale, weathered grey of stone and cloud.","苍天之下的浅灰。"),
    ("xuanse","neutral","玄色","xuán sè","Profound Black","#2A2626","Near-black with hidden depth, revered as the color of heaven.","古人敬天的黑中带赤。"),
    ("zaose","neutral","皂色","zào sè","Soapnut Black","#1A1D29","Deep black of traditional soapnut dye.","皂荚染成的深黑。"),
    # ---- Earth 褐土系 ----
    ("chahe","earth","茶褐","chá hè","Tea Umber","#704E35","Dark tea-brown of well-aged utensils.","陈茶般的深褐。"),
    ("tuose","earth","驼色","tuó sè","Camel","#A88462","Warm tan of camel-hair cloth.","驼毛织物的暖棕。"),
    ("lise","earth","栗色","lì sè","Chestnut","#5C2E23","Rich brown-red of chestnut shells.","栗子壳的深棕红。"),
]

colors = [
    {
        "id": cid, "family": fam, "nameZh": zh, "pinyin": py,
        "nameEn": en, "hex": hx, "noteEn": ne, "noteZh": nz,
    }
    for cid, fam, zh, py, en, hx, ne, nz in C
]
assert len(colors) == 60, len(colors)
assert len({c["id"] for c in colors}) == 60

dataset = {
    "meta": {
        "name": "Han Colors - Traditional Chinese Color Library",
        "version": "1.0.0",
        "count": len(colors),
        "locales": ["zh-CN", "en"],
        "hexNote": "All hex values are hand-tuned approximations for screen display (sRGB), not copied from any published color book.",
    },
    "families": FAMILIES,
    "colors": colors,
}

json_path = os.path.join(DATA, "colors.json")
with open(json_path, "w", encoding="utf-8") as f:
    json.dump(dataset, f, ensure_ascii=False, indent=2)

csv_path = os.path.join(DATA, "colors-table.csv")
with open(csv_path, "w", encoding="utf-8-sig", newline="") as f:
    w = csv.writer(f)
    w.writerow(["id", "family", "nameZh", "pinyin", "nameEn", "hex", "noteEn", "noteZh"])
    for c in colors:
        w.writerow([c["id"], c["family"], c["nameZh"], c["pinyin"], c["nameEn"], c["hex"], c["noteEn"], c["noteZh"]])

# ---------- palette preview PNG ----------
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib import font_manager
from matplotlib.patches import Rectangle

def find_cjk_font():
    preferred = ["Microsoft YaHei", "Noto Sans CJK SC", "Source Han Sans SC",
                 "Source Han Sans CN", "SimHei", "PingFang SC", "WenQuanYi Zen Hei"]
    installed = {f.name for f in font_manager.fontManager.ttflist}
    for name in preferred:
        if name in installed:
            return name
    for f in font_manager.fontManager.ttflist:
        if "CJK" in f.name or "Han" in f.name or "Hei" in f.name:
            return f.name
    return "sans-serif"

font = find_cjk_font()
plt.rcParams["font.family"] = font
plt.rcParams["axes.unicode_minus"] = False

def luminance(hex_color):
    h = hex_color.lstrip("#")
    r, g, b = (int(h[i:i+2], 16) / 255 for i in (0, 2, 4))
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

cols, rows = 10, 6
cw, ch = 1.0, 1.5
fig_w, fig_h = cols * cw, rows * ch + 0.45
fig = plt.figure(figsize=(fig_w * 1.15, fig_h * 1.15), dpi=120)
ax = fig.add_axes([0, 0, 1, 1])
ax.set_xlim(0, cols * cw)
ax.set_ylim(-0.45, rows * ch)
ax.axis("off")
fig.patch.set_facecolor("#FAFAF7")

ax.text(0.15, -0.30, "Han Colors · 60 Traditional Chinese Colors",
        fontsize=17, fontweight="bold", color="#333333", va="center")
ax.text(cols * cw - 0.15, -0.30, "screen-tuned sRGB values · v1.0",
        fontsize=10, color="#999999", va="center", ha="right")

for i, c in enumerate(colors):
    row, col = divmod(i, cols)
    x = col * cw
    y = (rows - 1 - row) * ch
    ax.add_patch(Rectangle((x + 0.03, y + 0.03), cw - 0.06, ch - 0.06,
                           facecolor=c["hex"], edgecolor="none"))
    tc = "#FFFFFF" if luminance(c["hex"]) < 0.55 else "#2B2B2B"
    ax.text(x + 0.12, y + 0.62, c["nameZh"], fontsize=15, fontweight="bold",
            color=tc, va="center")
    ax.text(x + 0.12, y + 0.40, c["nameEn"], fontsize=7.2, color=tc, va="center")
    ax.text(x + 0.12, y + 0.22, f"{c['pinyin']}  {c['hex']}", fontsize=6.2,
            color=tc, va="center", alpha=0.85)

png_path = os.path.join(DATA, "palette.png")
fig.savefig(png_path, dpi=120, facecolor=fig.get_facecolor())
plt.close(fig)

print("font:", font)
print("json:", json_path, os.path.getsize(json_path), "bytes")
print("csv :", csv_path, os.path.getsize(csv_path), "bytes")
print("png :", png_path, os.path.getsize(png_path), "bytes")
