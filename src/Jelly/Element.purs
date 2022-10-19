module Jelly.Element where

import Jelly.Data.Component (Component, el, el', voidEl, voidEl')
import Jelly.Data.Prop (Prop)

html :: forall context. Array Prop -> Component context -> Component context
html = el "html"

base :: forall context. Array Prop -> Component context
base = voidEl "base"

head :: forall context. Array Prop -> Component context -> Component context
head = el "head"

link :: forall context. Array Prop -> Component context
link = voidEl "link"

meta :: forall context. Array Prop -> Component context
meta = voidEl "meta"

style :: forall context. Array Prop -> Component context -> Component context
style = el "style"

title :: forall context. Array Prop -> Component context -> Component context
title = el "title"

body :: forall context. Array Prop -> Component context -> Component context
body = el "body"

address :: forall context. Array Prop -> Component context -> Component context
address = el "address"

article :: forall context. Array Prop -> Component context -> Component context
article = el "article"

aside :: forall context. Array Prop -> Component context -> Component context
aside = el "aside"

footer :: forall context. Array Prop -> Component context -> Component context
footer = el "footer"

header :: forall context. Array Prop -> Component context -> Component context
header = el "header"

h1 :: forall context. Array Prop -> Component context -> Component context
h1 = el "h1"

h2 :: forall context. Array Prop -> Component context -> Component context
h2 = el "h2"

h3 :: forall context. Array Prop -> Component context -> Component context
h3 = el "h3"

h4 :: forall context. Array Prop -> Component context -> Component context
h4 = el "h4"

h5 :: forall context. Array Prop -> Component context -> Component context
h5 = el "h5"

h6 :: forall context. Array Prop -> Component context -> Component context
h6 = el "h6"

main :: forall context. Array Prop -> Component context -> Component context
main = el "main"

nav :: forall context. Array Prop -> Component context -> Component context
nav = el "nav"

section :: forall context. Array Prop -> Component context -> Component context
section = el "section"

blockquote :: forall context. Array Prop -> Component context -> Component context
blockquote = el "blockquote"

dd :: forall context. Array Prop -> Component context -> Component context
dd = el "dd"

div :: forall context. Array Prop -> Component context -> Component context
div = el "div"

dl :: forall context. Array Prop -> Component context -> Component context
dl = el "dl"

dt :: forall context. Array Prop -> Component context -> Component context
dt = el "dt"

figcaption :: forall context. Array Prop -> Component context -> Component context
figcaption = el "figcaption"

figure :: forall context. Array Prop -> Component context -> Component context
figure = el "figure"

hr :: forall context. Array Prop -> Component context
hr = voidEl "hr"

li :: forall context. Array Prop -> Component context -> Component context
li = el "li"

menu :: forall context. Array Prop -> Component context -> Component context
menu = el "menu"

ol :: forall context. Array Prop -> Component context -> Component context
ol = el "ol"

p :: forall context. Array Prop -> Component context -> Component context
p = el "p"

pre :: forall context. Array Prop -> Component context -> Component context
pre = el "pre"

ul :: forall context. Array Prop -> Component context -> Component context
ul = el "ul"

a :: forall context. Array Prop -> Component context -> Component context
a = el "a"

abbr :: forall context. Array Prop -> Component context -> Component context
abbr = el "abbr"

b :: forall context. Array Prop -> Component context -> Component context
b = el "b"

bdi :: forall context. Array Prop -> Component context -> Component context
bdi = el "bdi"

bdo :: forall context. Array Prop -> Component context -> Component context
bdo = el "bdo"

br :: forall context. Array Prop -> Component context
br = voidEl "br"

cite :: forall context. Array Prop -> Component context -> Component context
cite = el "cite"

code :: forall context. Array Prop -> Component context -> Component context
code = el "code"

data_ :: forall context. Array Prop -> Component context -> Component context
data_ = el "data"

dfn :: forall context. Array Prop -> Component context -> Component context
dfn = el "dfn"

em :: forall context. Array Prop -> Component context -> Component context
em = el "em"

i :: forall context. Array Prop -> Component context -> Component context
i = el "i"

kbd :: forall context. Array Prop -> Component context -> Component context
kbd = el "kbd"

mark :: forall context. Array Prop -> Component context -> Component context
mark = el "mark"

q :: forall context. Array Prop -> Component context -> Component context
q = el "q"

rp :: forall context. Array Prop -> Component context -> Component context
rp = el "rp"

rt :: forall context. Array Prop -> Component context -> Component context
rt = el "rt"

ruby :: forall context. Array Prop -> Component context -> Component context
ruby = el "ruby"

s :: forall context. Array Prop -> Component context -> Component context
s = el "s"

samp :: forall context. Array Prop -> Component context -> Component context
samp = el "samp"

small :: forall context. Array Prop -> Component context -> Component context
small = el "small"

span :: forall context. Array Prop -> Component context -> Component context
span = el "span"

strong :: forall context. Array Prop -> Component context -> Component context
strong = el "strong"

sub :: forall context. Array Prop -> Component context -> Component context
sub = el "sub"

sup :: forall context. Array Prop -> Component context -> Component context
sup = el "sup"

time :: forall context. Array Prop -> Component context -> Component context
time = el "time"

u :: forall context. Array Prop -> Component context -> Component context
u = el "u"

var :: forall context. Array Prop -> Component context -> Component context
var = el "var"

wbr :: forall context. Array Prop -> Component context
wbr = voidEl "wbr"

area :: forall context. Array Prop -> Component context
area = voidEl "area"

audio :: forall context. Array Prop -> Component context -> Component context
audio = el "audio"

img :: forall context. Array Prop -> Component context
img = voidEl "img"

map :: forall context. Array Prop -> Component context -> Component context
map = el "map"

track :: forall context. Array Prop -> Component context
track = voidEl "track"

video :: forall context. Array Prop -> Component context -> Component context
video = el "video"

embed :: forall context. Array Prop -> Component context
embed = voidEl "embed"

iframe :: forall context. Array Prop -> Component context -> Component context
iframe = el "iframe"

object :: forall context. Array Prop -> Component context -> Component context
object = el "object"

picture :: forall context. Array Prop -> Component context -> Component context
picture = el "picture"

portal :: forall context. Array Prop -> Component context -> Component context
portal = el "portal"

source :: forall context. Array Prop -> Component context
source = voidEl "source"

svg :: forall context. Array Prop -> Component context -> Component context
svg = el "svg"

math :: forall context. Array Prop -> Component context -> Component context
math = el "math"

canvas :: forall context. Array Prop -> Component context -> Component context
canvas = el "canvas"

noscript :: forall context. Array Prop -> Component context -> Component context
noscript = el "noscript"

script :: forall context. Array Prop -> Component context -> Component context
script = el "script"

del :: forall context. Array Prop -> Component context -> Component context
del = el "del"

ins :: forall context. Array Prop -> Component context -> Component context
ins = el "ins"

caption :: forall context. Array Prop -> Component context -> Component context
caption = el "caption"

col :: forall context. Array Prop -> Component context
col = voidEl "col"

colgroup :: forall context. Array Prop -> Component context -> Component context
colgroup = el "colgroup"

table :: forall context. Array Prop -> Component context -> Component context
table = el "table"

tbody :: forall context. Array Prop -> Component context -> Component context
tbody = el "tbody"

td :: forall context. Array Prop -> Component context -> Component context
td = el "td"

tfoot :: forall context. Array Prop -> Component context -> Component context
tfoot = el "tfoot"

th :: forall context. Array Prop -> Component context -> Component context
th = el "th"

thead :: forall context. Array Prop -> Component context -> Component context
thead = el "thead"

tr :: forall context. Array Prop -> Component context -> Component context
tr = el "tr"

button :: forall context. Array Prop -> Component context -> Component context
button = el "button"

datalist :: forall context. Array Prop -> Component context -> Component context
datalist = el "datalist"

fieldset :: forall context. Array Prop -> Component context -> Component context
fieldset = el "fieldset"

form :: forall context. Array Prop -> Component context -> Component context
form = el "form"

input :: forall context. Array Prop -> Component context
input = voidEl "input"

label :: forall context. Array Prop -> Component context -> Component context
label = el "label"

legend :: forall context. Array Prop -> Component context -> Component context
legend = el "legend"

meter :: forall context. Array Prop -> Component context -> Component context
meter = el "meter"

optgroup :: forall context. Array Prop -> Component context -> Component context
optgroup = el "optgroup"

option :: forall context. Array Prop -> Component context -> Component context
option = el "option"

output :: forall context. Array Prop -> Component context -> Component context
output = el "output"

progress :: forall context. Array Prop -> Component context -> Component context
progress = el "progress"

select :: forall context. Array Prop -> Component context -> Component context
select = el "select"

textarea :: forall context. Array Prop -> Component context -> Component context
textarea = el "textarea"

details :: forall context. Array Prop -> Component context -> Component context
details = el "details"

dialog :: forall context. Array Prop -> Component context -> Component context
dialog = el "dialog"

summary :: forall context. Array Prop -> Component context -> Component context
summary = el "summary"

slot :: forall context. Array Prop -> Component context -> Component context
slot = el "slot"

template :: forall context. Array Prop -> Component context -> Component context
template = el "template"

html' :: forall context. Component context -> Component context
html' = el' "html"

head' :: forall context. Component context -> Component context
head' = el' "head"

title' :: forall context. Component context -> Component context
title' = el' "title"

base' :: forall context. Component context -> Component context
base' = el' "base"

link' :: forall context. Component context -> Component context
link' = el' "link"

meta' :: forall context. Component context -> Component context
meta' = el' "meta"

style' :: forall context. Component context -> Component context
style' = el' "style"

body' :: forall context. Component context -> Component context
body' = el' "body"

address' :: forall context. Component context -> Component context
address' = el' "address"

article' :: forall context. Component context -> Component context
article' = el' "article"

aside' :: forall context. Component context -> Component context
aside' = el' "aside"

footer' :: forall context. Component context -> Component context
footer' = el' "footer"

header' :: forall context. Component context -> Component context
header' = el' "header"

h1' :: forall context. Component context -> Component context
h1' = el' "h1"

h2' :: forall context. Component context -> Component context
h2' = el' "h2"

h3' :: forall context. Component context -> Component context
h3' = el' "h3"

h4' :: forall context. Component context -> Component context
h4' = el' "h4"

h5' :: forall context. Component context -> Component context
h5' = el' "h5"

h6' :: forall context. Component context -> Component context
h6' = el' "h6"

main' :: forall context. Component context -> Component context
main' = el' "main"

nav' :: forall context. Component context -> Component context
nav' = el' "nav"

section' :: forall context. Component context -> Component context
section' = el' "section"

blockquote' :: forall context. Component context -> Component context
blockquote' = el' "blockquote"

dd' :: forall context. Component context -> Component context
dd' = el' "dd"

div' :: forall context. Component context -> Component context
div' = el' "div"

dl' :: forall context. Component context -> Component context
dl' = el' "dl"

dt' :: forall context. Component context -> Component context
dt' = el' "dt"

figcaption' :: forall context. Component context -> Component context
figcaption' = el' "figcaption"

figure' :: forall context. Component context -> Component context
figure' = el' "figure"

hr' :: forall context. Component context
hr' = voidEl' "hr"

li' :: forall context. Component context -> Component context
li' = el' "li"

menu' :: forall context. Component context -> Component context
menu' = el' "menu"

ol' :: forall context. Component context -> Component context
ol' = el' "ol"

p' :: forall context. Component context -> Component context
p' = el' "p"

pre' :: forall context. Component context -> Component context
pre' = el' "pre"

ul' :: forall context. Component context -> Component context
ul' = el' "ul"

a' :: forall context. Component context -> Component context
a' = el' "a"

abbr' :: forall context. Component context -> Component context
abbr' = el' "abbr"

b' :: forall context. Component context -> Component context
b' = el' "b"

bdi' :: forall context. Component context -> Component context
bdi' = el' "bdi"

bdo' :: forall context. Component context -> Component context
bdo' = el' "bdo"

br' :: forall context. Component context
br' = voidEl' "br"

cite' :: forall context. Component context -> Component context
cite' = el' "cite"

code' :: forall context. Component context -> Component context
code' = el' "code"

data_' :: forall context. Component context -> Component context
data_' = el' "data"

dfn' :: forall context. Component context -> Component context
dfn' = el' "dfn"

em' :: forall context. Component context -> Component context
em' = el' "em"

i' :: forall context. Component context -> Component context
i' = el' "i"

kbd' :: forall context. Component context -> Component context
kbd' = el' "kbd"

mark' :: forall context. Component context -> Component context
mark' = el' "mark"

q' :: forall context. Component context -> Component context
q' = el' "q"

rp' :: forall context. Component context -> Component context
rp' = el' "rp"

rt' :: forall context. Component context -> Component context
rt' = el' "rt"

ruby' :: forall context. Component context -> Component context
ruby' = el' "ruby"

s' :: forall context. Component context -> Component context
s' = el' "s"

samp' :: forall context. Component context -> Component context
samp' = el' "samp"

small' :: forall context. Component context -> Component context
small' = el' "small"

span' :: forall context. Component context -> Component context
span' = el' "span"

strong' :: forall context. Component context -> Component context
strong' = el' "strong"

sub' :: forall context. Component context -> Component context
sub' = el' "sub"

sup' :: forall context. Component context -> Component context
sup' = el' "sup"

time' :: forall context. Component context -> Component context
time' = el' "time"

u' :: forall context. Component context -> Component context
u' = el' "u"

var' :: forall context. Component context -> Component context
var' = el' "var"

wbr' :: forall context. Component context
wbr' = voidEl' "wbr"

area' :: forall context. Component context
area' = voidEl' "area"

audio' :: forall context. Component context -> Component context
audio' = el' "audio"

img' :: forall context. Component context
img' = voidEl' "img"

map' :: forall context. Component context -> Component context
map' = el' "map"

track' :: forall context. Component context
track' = voidEl' "track"

video' :: forall context. Component context -> Component context
video' = el' "video"

embed' :: forall context. Component context
embed' = voidEl' "embed"

iframe' :: forall context. Component context -> Component context
iframe' = el' "iframe"

object' :: forall context. Component context -> Component context
object' = el' "object"

picture' :: forall context. Component context -> Component context
picture' = el' "picture"

portal' :: forall context. Component context -> Component context
portal' = el' "portal"

source' :: forall context. Component context
source' = voidEl' "source"

svg' :: forall context. Component context -> Component context
svg' = el' "svg"

math' :: forall context. Component context -> Component context
math' = el' "math"

canvas' :: forall context. Component context -> Component context
canvas' = el' "canvas"

noscript' :: forall context. Component context -> Component context
noscript' = el' "noscript"

script' :: forall context. Component context -> Component context
script' = el' "script"

del'' :: forall context. Component context -> Component context
del'' = el' "del'"

ins' :: forall context. Component context -> Component context
ins' = el' "ins"

caption' :: forall context. Component context -> Component context
caption' = el' "caption"

col' :: forall context. Component context
col' = voidEl' "col"

colgroup' :: forall context. Component context -> Component context
colgroup' = el' "colgroup"

table' :: forall context. Component context -> Component context
table' = el' "table"

tbody' :: forall context. Component context -> Component context
tbody' = el' "tbody"

td' :: forall context. Component context -> Component context
td' = el' "td"

tfoot' :: forall context. Component context -> Component context
tfoot' = el' "tfoot"

th' :: forall context. Component context -> Component context
th' = el' "th"

thead' :: forall context. Component context -> Component context
thead' = el' "thead"

tr' :: forall context. Component context -> Component context
tr' = el' "tr"

button' :: forall context. Component context -> Component context
button' = el' "button"

datalist' :: forall context. Component context -> Component context
datalist' = el' "datalist"

fiel'dset' :: forall context. Component context -> Component context
fiel'dset' = el' "fiel'dset"

form' :: forall context. Component context -> Component context
form' = el' "form"

input' :: forall context. Component context
input' = voidEl' "input"

label'' :: forall context. Component context -> Component context
label'' = el' "label'"

legend' :: forall context. Component context -> Component context
legend' = el' "legend"

meter' :: forall context. Component context -> Component context
meter' = el' "meter"

optgroup' :: forall context. Component context -> Component context
optgroup' = el' "optgroup"

option' :: forall context. Component context -> Component context
option' = el' "option"

output' :: forall context. Component context -> Component context
output' = el' "output"

progress' :: forall context. Component context -> Component context
progress' = el' "progress"

select' :: forall context. Component context -> Component context
select' = el' "sel'ect"

textarea' :: forall context. Component context -> Component context
textarea' = el' "textarea"

details' :: forall context. Component context -> Component context
details' = el' "details"

dialog' :: forall context. Component context -> Component context
dialog' = el' "dialog"

summary' :: forall context. Component context -> Component context
summary' = el' "summary"

slot' :: forall context. Component context -> Component context
slot' = el' "slot"

template' :: forall context. Component context -> Component context
template' = el' "template"
