module Jelly.Element where

import Jelly.Component (Component, el, el', elVoid, elVoid')
import Jelly.Prop (Prop)

html :: forall m. Array (Prop m) -> Component m -> Component m
html = el "html"

base :: forall m. Array (Prop m) -> Component m
base = elVoid "base"

head :: forall m. Array (Prop m) -> Component m -> Component m
head = el "head"

link :: forall m. Array (Prop m) -> Component m
link = elVoid "link"

meta :: forall m. Array (Prop m) -> Component m
meta = elVoid "meta"

style :: forall m. Array (Prop m) -> Component m -> Component m
style = el "style"

title :: forall m. Array (Prop m) -> Component m -> Component m
title = el "title"

body :: forall m. Array (Prop m) -> Component m -> Component m
body = el "body"

address :: forall m. Array (Prop m) -> Component m -> Component m
address = el "address"

article :: forall m. Array (Prop m) -> Component m -> Component m
article = el "article"

aside :: forall m. Array (Prop m) -> Component m -> Component m
aside = el "aside"

footer :: forall m. Array (Prop m) -> Component m -> Component m
footer = el "footer"

header :: forall m. Array (Prop m) -> Component m -> Component m
header = el "header"

h1 :: forall m. Array (Prop m) -> Component m -> Component m
h1 = el "h1"

h2 :: forall m. Array (Prop m) -> Component m -> Component m
h2 = el "h2"

h3 :: forall m. Array (Prop m) -> Component m -> Component m
h3 = el "h3"

h4 :: forall m. Array (Prop m) -> Component m -> Component m
h4 = el "h4"

h5 :: forall m. Array (Prop m) -> Component m -> Component m
h5 = el "h5"

h6 :: forall m. Array (Prop m) -> Component m -> Component m
h6 = el "h6"

main :: forall m. Array (Prop m) -> Component m -> Component m
main = el "main"

nav :: forall m. Array (Prop m) -> Component m -> Component m
nav = el "nav"

section :: forall m. Array (Prop m) -> Component m -> Component m
section = el "section"

blockquote :: forall m. Array (Prop m) -> Component m -> Component m
blockquote = el "blockquote"

dd :: forall m. Array (Prop m) -> Component m -> Component m
dd = el "dd"

div :: forall m. Array (Prop m) -> Component m -> Component m
div = el "div"

dl :: forall m. Array (Prop m) -> Component m -> Component m
dl = el "dl"

dt :: forall m. Array (Prop m) -> Component m -> Component m
dt = el "dt"

figcaption :: forall m. Array (Prop m) -> Component m -> Component m
figcaption = el "figcaption"

figure :: forall m. Array (Prop m) -> Component m -> Component m
figure = el "figure"

hr :: forall m. Array (Prop m) -> Component m
hr = elVoid "hr"

li :: forall m. Array (Prop m) -> Component m -> Component m
li = el "li"

menu :: forall m. Array (Prop m) -> Component m -> Component m
menu = el "menu"

ol :: forall m. Array (Prop m) -> Component m -> Component m
ol = el "ol"

p :: forall m. Array (Prop m) -> Component m -> Component m
p = el "p"

pre :: forall m. Array (Prop m) -> Component m -> Component m
pre = el "pre"

ul :: forall m. Array (Prop m) -> Component m -> Component m
ul = el "ul"

a :: forall m. Array (Prop m) -> Component m -> Component m
a = el "a"

abbr :: forall m. Array (Prop m) -> Component m -> Component m
abbr = el "abbr"

b :: forall m. Array (Prop m) -> Component m -> Component m
b = el "b"

bdi :: forall m. Array (Prop m) -> Component m -> Component m
bdi = el "bdi"

bdo :: forall m. Array (Prop m) -> Component m -> Component m
bdo = el "bdo"

br :: forall m. Array (Prop m) -> Component m
br = elVoid "br"

cite :: forall m. Array (Prop m) -> Component m -> Component m
cite = el "cite"

code :: forall m. Array (Prop m) -> Component m -> Component m
code = el "code"

data_ :: forall m. Array (Prop m) -> Component m -> Component m
data_ = el "data"

dfn :: forall m. Array (Prop m) -> Component m -> Component m
dfn = el "dfn"

em :: forall m. Array (Prop m) -> Component m -> Component m
em = el "em"

i :: forall m. Array (Prop m) -> Component m -> Component m
i = el "i"

kbd :: forall m. Array (Prop m) -> Component m -> Component m
kbd = el "kbd"

mark :: forall m. Array (Prop m) -> Component m -> Component m
mark = el "mark"

q :: forall m. Array (Prop m) -> Component m -> Component m
q = el "q"

rp :: forall m. Array (Prop m) -> Component m -> Component m
rp = el "rp"

rt :: forall m. Array (Prop m) -> Component m -> Component m
rt = el "rt"

ruby :: forall m. Array (Prop m) -> Component m -> Component m
ruby = el "ruby"

s :: forall m. Array (Prop m) -> Component m -> Component m
s = el "s"

samp :: forall m. Array (Prop m) -> Component m -> Component m
samp = el "samp"

small :: forall m. Array (Prop m) -> Component m -> Component m
small = el "small"

span :: forall m. Array (Prop m) -> Component m -> Component m
span = el "span"

strong :: forall m. Array (Prop m) -> Component m -> Component m
strong = el "strong"

sub :: forall m. Array (Prop m) -> Component m -> Component m
sub = el "sub"

sup :: forall m. Array (Prop m) -> Component m -> Component m
sup = el "sup"

time :: forall m. Array (Prop m) -> Component m -> Component m
time = el "time"

u :: forall m. Array (Prop m) -> Component m -> Component m
u = el "u"

var :: forall m. Array (Prop m) -> Component m -> Component m
var = el "var"

wbr :: forall m. Array (Prop m) -> Component m
wbr = elVoid "wbr"

area :: forall m. Array (Prop m) -> Component m
area = elVoid "area"

audio :: forall m. Array (Prop m) -> Component m -> Component m
audio = el "audio"

img :: forall m. Array (Prop m) -> Component m
img = elVoid "img"

map :: forall m. Array (Prop m) -> Component m -> Component m
map = el "map"

track :: forall m. Array (Prop m) -> Component m
track = elVoid "track"

video :: forall m. Array (Prop m) -> Component m -> Component m
video = el "video"

embed :: forall m. Array (Prop m) -> Component m
embed = elVoid "embed"

iframe :: forall m. Array (Prop m) -> Component m -> Component m
iframe = el "iframe"

object :: forall m. Array (Prop m) -> Component m -> Component m
object = el "object"

picture :: forall m. Array (Prop m) -> Component m -> Component m
picture = el "picture"

portal :: forall m. Array (Prop m) -> Component m -> Component m
portal = el "portal"

source :: forall m. Array (Prop m) -> Component m
source = elVoid "source"

svg :: forall m. Array (Prop m) -> Component m -> Component m
svg = el "svg"

math :: forall m. Array (Prop m) -> Component m -> Component m
math = el "math"

canvas :: forall m. Array (Prop m) -> Component m -> Component m
canvas = el "canvas"

noscript :: forall m. Array (Prop m) -> Component m -> Component m
noscript = el "noscript"

script :: forall m. Array (Prop m) -> Component m -> Component m
script = el "script"

del :: forall m. Array (Prop m) -> Component m -> Component m
del = el "del"

ins :: forall m. Array (Prop m) -> Component m -> Component m
ins = el "ins"

caption :: forall m. Array (Prop m) -> Component m -> Component m
caption = el "caption"

col :: forall m. Array (Prop m) -> Component m
col = elVoid "col"

colgroup :: forall m. Array (Prop m) -> Component m -> Component m
colgroup = el "colgroup"

table :: forall m. Array (Prop m) -> Component m -> Component m
table = el "table"

tbody :: forall m. Array (Prop m) -> Component m -> Component m
tbody = el "tbody"

td :: forall m. Array (Prop m) -> Component m -> Component m
td = el "td"

tfoot :: forall m. Array (Prop m) -> Component m -> Component m
tfoot = el "tfoot"

th :: forall m. Array (Prop m) -> Component m -> Component m
th = el "th"

thead :: forall m. Array (Prop m) -> Component m -> Component m
thead = el "thead"

tr :: forall m. Array (Prop m) -> Component m -> Component m
tr = el "tr"

button :: forall m. Array (Prop m) -> Component m -> Component m
button = el "button"

datalist :: forall m. Array (Prop m) -> Component m -> Component m
datalist = el "datalist"

fieldset :: forall m. Array (Prop m) -> Component m -> Component m
fieldset = el "fieldset"

form :: forall m. Array (Prop m) -> Component m -> Component m
form = el "form"

input :: forall m. Array (Prop m) -> Component m
input = elVoid "input"

label :: forall m. Array (Prop m) -> Component m -> Component m
label = el "label"

legend :: forall m. Array (Prop m) -> Component m -> Component m
legend = el "legend"

meter :: forall m. Array (Prop m) -> Component m -> Component m
meter = el "meter"

optgroup :: forall m. Array (Prop m) -> Component m -> Component m
optgroup = el "optgroup"

option :: forall m. Array (Prop m) -> Component m -> Component m
option = el "option"

output :: forall m. Array (Prop m) -> Component m -> Component m
output = el "output"

progress :: forall m. Array (Prop m) -> Component m -> Component m
progress = el "progress"

select :: forall m. Array (Prop m) -> Component m -> Component m
select = el "select"

textarea :: forall m. Array (Prop m) -> Component m -> Component m
textarea = el "textarea"

details :: forall m. Array (Prop m) -> Component m -> Component m
details = el "details"

dialog :: forall m. Array (Prop m) -> Component m -> Component m
dialog = el "dialog"

summary :: forall m. Array (Prop m) -> Component m -> Component m
summary = el "summary"

slot :: forall m. Array (Prop m) -> Component m -> Component m
slot = el "slot"

template :: forall m. Array (Prop m) -> Component m -> Component m
template = el "template"

html' :: forall m. Component m -> Component m
html' = el' "html"

head' :: forall m. Component m -> Component m
head' = el' "head"

title' :: forall m. Component m -> Component m
title' = el' "title"

base' :: forall m. Component m -> Component m
base' = el' "base"

link' :: forall m. Component m -> Component m
link' = el' "link"

meta' :: forall m. Component m -> Component m
meta' = el' "meta"

style' :: forall m. Component m -> Component m
style' = el' "style"

body' :: forall m. Component m -> Component m
body' = el' "body"

address' :: forall m. Component m -> Component m
address' = el' "address"

article' :: forall m. Component m -> Component m
article' = el' "article"

aside' :: forall m. Component m -> Component m
aside' = el' "aside"

footer' :: forall m. Component m -> Component m
footer' = el' "footer"

header' :: forall m. Component m -> Component m
header' = el' "header"

h1' :: forall m. Component m -> Component m
h1' = el' "h1"

h2' :: forall m. Component m -> Component m
h2' = el' "h2"

h3' :: forall m. Component m -> Component m
h3' = el' "h3"

h4' :: forall m. Component m -> Component m
h4' = el' "h4"

h5' :: forall m. Component m -> Component m
h5' = el' "h5"

h6' :: forall m. Component m -> Component m
h6' = el' "h6"

main' :: forall m. Component m -> Component m
main' = el' "main"

nav' :: forall m. Component m -> Component m
nav' = el' "nav"

section' :: forall m. Component m -> Component m
section' = el' "section"

blockquote' :: forall m. Component m -> Component m
blockquote' = el' "blockquote"

dd' :: forall m. Component m -> Component m
dd' = el' "dd"

div' :: forall m. Component m -> Component m
div' = el' "div"

dl' :: forall m. Component m -> Component m
dl' = el' "dl"

dt' :: forall m. Component m -> Component m
dt' = el' "dt"

figcaption' :: forall m. Component m -> Component m
figcaption' = el' "figcaption"

figure' :: forall m. Component m -> Component m
figure' = el' "figure"

hr' :: forall m. Component m
hr' = elVoid' "hr"

li' :: forall m. Component m -> Component m
li' = el' "li"

menu' :: forall m. Component m -> Component m
menu' = el' "menu"

ol' :: forall m. Component m -> Component m
ol' = el' "ol"

p' :: forall m. Component m -> Component m
p' = el' "p"

pre' :: forall m. Component m -> Component m
pre' = el' "pre"

ul' :: forall m. Component m -> Component m
ul' = el' "ul"

a' :: forall m. Component m -> Component m
a' = el' "a"

abbr' :: forall m. Component m -> Component m
abbr' = el' "abbr"

b' :: forall m. Component m -> Component m
b' = el' "b"

bdi' :: forall m. Component m -> Component m
bdi' = el' "bdi"

bdo' :: forall m. Component m -> Component m
bdo' = el' "bdo"

br' :: forall m. Component m
br' = elVoid' "br"

cite' :: forall m. Component m -> Component m
cite' = el' "cite"

code' :: forall m. Component m -> Component m
code' = el' "code"

data_' :: forall m. Component m -> Component m
data_' = el' "data"

dfn' :: forall m. Component m -> Component m
dfn' = el' "dfn"

em' :: forall m. Component m -> Component m
em' = el' "em"

i' :: forall m. Component m -> Component m
i' = el' "i"

kbd' :: forall m. Component m -> Component m
kbd' = el' "kbd"

mark' :: forall m. Component m -> Component m
mark' = el' "mark"

q' :: forall m. Component m -> Component m
q' = el' "q"

rp' :: forall m. Component m -> Component m
rp' = el' "rp"

rt' :: forall m. Component m -> Component m
rt' = el' "rt"

ruby' :: forall m. Component m -> Component m
ruby' = el' "ruby"

s' :: forall m. Component m -> Component m
s' = el' "s"

samp' :: forall m. Component m -> Component m
samp' = el' "samp"

small' :: forall m. Component m -> Component m
small' = el' "small"

span' :: forall m. Component m -> Component m
span' = el' "span"

strong' :: forall m. Component m -> Component m
strong' = el' "strong"

sub' :: forall m. Component m -> Component m
sub' = el' "sub"

sup' :: forall m. Component m -> Component m
sup' = el' "sup"

time' :: forall m. Component m -> Component m
time' = el' "time"

u' :: forall m. Component m -> Component m
u' = el' "u"

var' :: forall m. Component m -> Component m
var' = el' "var"

wbr' :: forall m. Component m
wbr' = elVoid' "wbr"

area' :: forall m. Component m
area' = elVoid' "area"

audio' :: forall m. Component m -> Component m
audio' = el' "audio"

img' :: forall m. Component m
img' = elVoid' "img"

map' :: forall m. Component m -> Component m
map' = el' "map"

track' :: forall m. Component m
track' = elVoid' "track"

video' :: forall m. Component m -> Component m
video' = el' "video"

embed' :: forall m. Component m
embed' = elVoid' "embed"

iframe' :: forall m. Component m -> Component m
iframe' = el' "iframe"

object' :: forall m. Component m -> Component m
object' = el' "object"

picture' :: forall m. Component m -> Component m
picture' = el' "picture"

portal' :: forall m. Component m -> Component m
portal' = el' "portal"

source' :: forall m. Component m
source' = elVoid' "source"

svg' :: forall m. Component m -> Component m
svg' = el' "svg"

math' :: forall m. Component m -> Component m
math' = el' "math"

canvas' :: forall m. Component m -> Component m
canvas' = el' "canvas"

noscript' :: forall m. Component m -> Component m
noscript' = el' "noscript"

script' :: forall m. Component m -> Component m
script' = el' "script"

del'' :: forall m. Component m -> Component m
del'' = el' "del'"

ins' :: forall m. Component m -> Component m
ins' = el' "ins"

caption' :: forall m. Component m -> Component m
caption' = el' "caption"

col' :: forall m. Component m
col' = elVoid' "col"

colgroup' :: forall m. Component m -> Component m
colgroup' = el' "colgroup"

table' :: forall m. Component m -> Component m
table' = el' "table"

tbody' :: forall m. Component m -> Component m
tbody' = el' "tbody"

td' :: forall m. Component m -> Component m
td' = el' "td"

tfoot' :: forall m. Component m -> Component m
tfoot' = el' "tfoot"

th' :: forall m. Component m -> Component m
th' = el' "th"

thead' :: forall m. Component m -> Component m
thead' = el' "thead"

tr' :: forall m. Component m -> Component m
tr' = el' "tr"

button' :: forall m. Component m -> Component m
button' = el' "button"

datalist' :: forall m. Component m -> Component m
datalist' = el' "datalist"

fiel'dset' :: forall m. Component m -> Component m
fiel'dset' = el' "fiel'dset"

form' :: forall m. Component m -> Component m
form' = el' "form"

input' :: forall m. Component m
input' = elVoid' "input"

label'' :: forall m. Component m -> Component m
label'' = el' "label'"

legend' :: forall m. Component m -> Component m
legend' = el' "legend"

meter' :: forall m. Component m -> Component m
meter' = el' "meter"

optgroup' :: forall m. Component m -> Component m
optgroup' = el' "optgroup"

option' :: forall m. Component m -> Component m
option' = el' "option"

output' :: forall m. Component m -> Component m
output' = el' "output"

progress' :: forall m. Component m -> Component m
progress' = el' "progress"

select' :: forall m. Component m -> Component m
select' = el' "sel'ect"

textarea' :: forall m. Component m -> Component m
textarea' = el' "textarea"

details' :: forall m. Component m -> Component m
details' = el' "details"

dialog' :: forall m. Component m -> Component m
dialog' = el' "dialog"

summary' :: forall m. Component m -> Component m
summary' = el' "summary"

slot' :: forall m. Component m -> Component m
slot' = el' "slot"

template' :: forall m. Component m -> Component m
template' = el' "template"
