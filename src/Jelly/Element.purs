module Jelly.Element where

import Prelude

import Jelly.Component (class Component, el, el', elVoid, elVoid')
import Jelly.Prop (Prop)

html :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
html = el "html"

base :: forall m. Component m => Array (Prop m) -> m Unit
base = elVoid "base"

head :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
head = el "head"

link :: forall m. Component m => Array (Prop m) -> m Unit
link = elVoid "link"

meta :: forall m. Component m => Array (Prop m) -> m Unit
meta = elVoid "meta"

style :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
style = el "style"

title :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
title = el "title"

body :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
body = el "body"

address :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
address = el "address"

article :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
article = el "article"

aside :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
aside = el "aside"

footer :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
footer = el "footer"

header :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
header = el "header"

h1 :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
h1 = el "h1"

h2 :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
h2 = el "h2"

h3 :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
h3 = el "h3"

h4 :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
h4 = el "h4"

h5 :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
h5 = el "h5"

h6 :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
h6 = el "h6"

main :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
main = el "main"

nav :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
nav = el "nav"

section :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
section = el "section"

blockquote :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
blockquote = el "blockquote"

dd :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
dd = el "dd"

div :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
div = el "div"

dl :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
dl = el "dl"

dt :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
dt = el "dt"

figcaption :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
figcaption = el "figcaption"

figure :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
figure = el "figure"

hr :: forall m. Component m => Array (Prop m) -> m Unit
hr = elVoid "hr"

li :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
li = el "li"

menu :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
menu = el "menu"

ol :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
ol = el "ol"

p :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
p = el "p"

pre :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
pre = el "pre"

ul :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
ul = el "ul"

a :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
a = el "a"

abbr :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
abbr = el "abbr"

b :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
b = el "b"

bdi :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
bdi = el "bdi"

bdo :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
bdo = el "bdo"

br :: forall m. Component m => Array (Prop m) -> m Unit
br = elVoid "br"

cite :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
cite = el "cite"

code :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
code = el "code"

data_ :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
data_ = el "data"

dfn :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
dfn = el "dfn"

em :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
em = el "em"

i :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
i = el "i"

kbd :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
kbd = el "kbd"

mark :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
mark = el "mark"

q :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
q = el "q"

rp :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
rp = el "rp"

rt :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
rt = el "rt"

ruby :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
ruby = el "ruby"

s :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
s = el "s"

samp :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
samp = el "samp"

small :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
small = el "small"

span :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
span = el "span"

strong :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
strong = el "strong"

sub :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
sub = el "sub"

sup :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
sup = el "sup"

time :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
time = el "time"

u :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
u = el "u"

var :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
var = el "var"

wbr :: forall m. Component m => Array (Prop m) -> m Unit
wbr = elVoid "wbr"

area :: forall m. Component m => Array (Prop m) -> m Unit
area = elVoid "area"

audio :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
audio = el "audio"

img :: forall m. Component m => Array (Prop m) -> m Unit
img = elVoid "img"

map :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
map = el "map"

track :: forall m. Component m => Array (Prop m) -> m Unit
track = elVoid "track"

video :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
video = el "video"

embed :: forall m. Component m => Array (Prop m) -> m Unit
embed = elVoid "embed"

iframe :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
iframe = el "iframe"

object :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
object = el "object"

picture :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
picture = el "picture"

portal :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
portal = el "portal"

source :: forall m. Component m => Array (Prop m) -> m Unit
source = elVoid "source"

svg :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
svg = el "svg"

math :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
math = el "math"

canvas :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
canvas = el "canvas"

noscript :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
noscript = el "noscript"

script :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
script = el "script"

del :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
del = el "del"

ins :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
ins = el "ins"

caption :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
caption = el "caption"

col :: forall m. Component m => Array (Prop m) -> m Unit
col = elVoid "col"

colgroup :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
colgroup = el "colgroup"

table :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
table = el "table"

tbody :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
tbody = el "tbody"

td :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
td = el "td"

tfoot :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
tfoot = el "tfoot"

th :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
th = el "th"

thead :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
thead = el "thead"

tr :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
tr = el "tr"

button :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
button = el "button"

datalist :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
datalist = el "datalist"

fieldset :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
fieldset = el "fieldset"

form :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
form = el "form"

input :: forall m. Component m => Array (Prop m) -> m Unit
input = elVoid "input"

label :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
label = el "label"

legend :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
legend = el "legend"

meter :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
meter = el "meter"

optgroup :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
optgroup = el "optgroup"

option :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
option = el "option"

output :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
output = el "output"

progress :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
progress = el "progress"

select :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
select = el "select"

textarea :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
textarea = el "textarea"

details :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
details = el "details"

dialog :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
dialog = el "dialog"

summary :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
summary = el "summary"

slot :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
slot = el "slot"

template :: forall m. Component m => Array (Prop m) -> m Unit -> m Unit
template = el "template"

html' :: forall m. Component m => m Unit -> m Unit
html' = el' "html"

head' :: forall m. Component m => m Unit -> m Unit
head' = el' "head"

title' :: forall m. Component m => m Unit -> m Unit
title' = el' "title"

base' :: forall m. Component m => m Unit -> m Unit
base' = el' "base"

link' :: forall m. Component m => m Unit -> m Unit
link' = el' "link"

meta' :: forall m. Component m => m Unit -> m Unit
meta' = el' "meta"

style' :: forall m. Component m => m Unit -> m Unit
style' = el' "style"

body' :: forall m. Component m => m Unit -> m Unit
body' = el' "body"

address' :: forall m. Component m => m Unit -> m Unit
address' = el' "address"

article' :: forall m. Component m => m Unit -> m Unit
article' = el' "article"

aside' :: forall m. Component m => m Unit -> m Unit
aside' = el' "aside"

footer' :: forall m. Component m => m Unit -> m Unit
footer' = el' "footer"

header' :: forall m. Component m => m Unit -> m Unit
header' = el' "header"

h1' :: forall m. Component m => m Unit -> m Unit
h1' = el' "h1"

h2' :: forall m. Component m => m Unit -> m Unit
h2' = el' "h2"

h3' :: forall m. Component m => m Unit -> m Unit
h3' = el' "h3"

h4' :: forall m. Component m => m Unit -> m Unit
h4' = el' "h4"

h5' :: forall m. Component m => m Unit -> m Unit
h5' = el' "h5"

h6' :: forall m. Component m => m Unit -> m Unit
h6' = el' "h6"

main' :: forall m. Component m => m Unit -> m Unit
main' = el' "main"

nav' :: forall m. Component m => m Unit -> m Unit
nav' = el' "nav"

section' :: forall m. Component m => m Unit -> m Unit
section' = el' "section"

blockquote' :: forall m. Component m => m Unit -> m Unit
blockquote' = el' "blockquote"

dd' :: forall m. Component m => m Unit -> m Unit
dd' = el' "dd"

div' :: forall m. Component m => m Unit -> m Unit
div' = el' "div"

dl' :: forall m. Component m => m Unit -> m Unit
dl' = el' "dl"

dt' :: forall m. Component m => m Unit -> m Unit
dt' = el' "dt"

figcaption' :: forall m. Component m => m Unit -> m Unit
figcaption' = el' "figcaption"

figure' :: forall m. Component m => m Unit -> m Unit
figure' = el' "figure"

hr' :: forall m. Component m => m Unit
hr' = elVoid' "hr"

li' :: forall m. Component m => m Unit -> m Unit
li' = el' "li"

menu' :: forall m. Component m => m Unit -> m Unit
menu' = el' "menu"

ol' :: forall m. Component m => m Unit -> m Unit
ol' = el' "ol"

p' :: forall m. Component m => m Unit -> m Unit
p' = el' "p"

pre' :: forall m. Component m => m Unit -> m Unit
pre' = el' "pre"

ul' :: forall m. Component m => m Unit -> m Unit
ul' = el' "ul"

a' :: forall m. Component m => m Unit -> m Unit
a' = el' "a"

abbr' :: forall m. Component m => m Unit -> m Unit
abbr' = el' "abbr"

b' :: forall m. Component m => m Unit -> m Unit
b' = el' "b"

bdi' :: forall m. Component m => m Unit -> m Unit
bdi' = el' "bdi"

bdo' :: forall m. Component m => m Unit -> m Unit
bdo' = el' "bdo"

br' :: forall m. Component m => m Unit
br' = elVoid' "br"

cite' :: forall m. Component m => m Unit -> m Unit
cite' = el' "cite"

code' :: forall m. Component m => m Unit -> m Unit
code' = el' "code"

data_' :: forall m. Component m => m Unit -> m Unit
data_' = el' "data"

dfn' :: forall m. Component m => m Unit -> m Unit
dfn' = el' "dfn"

em' :: forall m. Component m => m Unit -> m Unit
em' = el' "em"

i' :: forall m. Component m => m Unit -> m Unit
i' = el' "i"

kbd' :: forall m. Component m => m Unit -> m Unit
kbd' = el' "kbd"

mark' :: forall m. Component m => m Unit -> m Unit
mark' = el' "mark"

q' :: forall m. Component m => m Unit -> m Unit
q' = el' "q"

rp' :: forall m. Component m => m Unit -> m Unit
rp' = el' "rp"

rt' :: forall m. Component m => m Unit -> m Unit
rt' = el' "rt"

ruby' :: forall m. Component m => m Unit -> m Unit
ruby' = el' "ruby"

s' :: forall m. Component m => m Unit -> m Unit
s' = el' "s"

samp' :: forall m. Component m => m Unit -> m Unit
samp' = el' "samp"

small' :: forall m. Component m => m Unit -> m Unit
small' = el' "small"

span' :: forall m. Component m => m Unit -> m Unit
span' = el' "span"

strong' :: forall m. Component m => m Unit -> m Unit
strong' = el' "strong"

sub' :: forall m. Component m => m Unit -> m Unit
sub' = el' "sub"

sup' :: forall m. Component m => m Unit -> m Unit
sup' = el' "sup"

time' :: forall m. Component m => m Unit -> m Unit
time' = el' "time"

u' :: forall m. Component m => m Unit -> m Unit
u' = el' "u"

var' :: forall m. Component m => m Unit -> m Unit
var' = el' "var"

wbr' :: forall m. Component m => m Unit
wbr' = elVoid' "wbr"

area' :: forall m. Component m => m Unit
area' = elVoid' "area"

audio' :: forall m. Component m => m Unit -> m Unit
audio' = el' "audio"

img' :: forall m. Component m => m Unit
img' = elVoid' "img"

map' :: forall m. Component m => m Unit -> m Unit
map' = el' "map"

track' :: forall m. Component m => m Unit
track' = elVoid' "track"

video' :: forall m. Component m => m Unit -> m Unit
video' = el' "video"

embed' :: forall m. Component m => m Unit
embed' = elVoid' "embed"

iframe' :: forall m. Component m => m Unit -> m Unit
iframe' = el' "iframe"

object' :: forall m. Component m => m Unit -> m Unit
object' = el' "object"

picture' :: forall m. Component m => m Unit -> m Unit
picture' = el' "picture"

portal' :: forall m. Component m => m Unit -> m Unit
portal' = el' "portal"

source' :: forall m. Component m => m Unit
source' = elVoid' "source"

svg' :: forall m. Component m => m Unit -> m Unit
svg' = el' "svg"

math' :: forall m. Component m => m Unit -> m Unit
math' = el' "math"

canvas' :: forall m. Component m => m Unit -> m Unit
canvas' = el' "canvas"

noscript' :: forall m. Component m => m Unit -> m Unit
noscript' = el' "noscript"

script' :: forall m. Component m => m Unit -> m Unit
script' = el' "script"

del'' :: forall m. Component m => m Unit -> m Unit
del'' = el' "del'"

ins' :: forall m. Component m => m Unit -> m Unit
ins' = el' "ins"

caption' :: forall m. Component m => m Unit -> m Unit
caption' = el' "caption"

col' :: forall m. Component m => m Unit
col' = elVoid' "col"

colgroup' :: forall m. Component m => m Unit -> m Unit
colgroup' = el' "colgroup"

table' :: forall m. Component m => m Unit -> m Unit
table' = el' "table"

tbody' :: forall m. Component m => m Unit -> m Unit
tbody' = el' "tbody"

td' :: forall m. Component m => m Unit -> m Unit
td' = el' "td"

tfoot' :: forall m. Component m => m Unit -> m Unit
tfoot' = el' "tfoot"

th' :: forall m. Component m => m Unit -> m Unit
th' = el' "th"

thead' :: forall m. Component m => m Unit -> m Unit
thead' = el' "thead"

tr' :: forall m. Component m => m Unit -> m Unit
tr' = el' "tr"

button' :: forall m. Component m => m Unit -> m Unit
button' = el' "button"

datalist' :: forall m. Component m => m Unit -> m Unit
datalist' = el' "datalist"

fiel'dset' :: forall m. Component m => m Unit -> m Unit
fiel'dset' = el' "fiel'dset"

form' :: forall m. Component m => m Unit -> m Unit
form' = el' "form"

input' :: forall m. Component m => m Unit
input' = elVoid' "input"

label'' :: forall m. Component m => m Unit -> m Unit
label'' = el' "label'"

legend' :: forall m. Component m => m Unit -> m Unit
legend' = el' "legend"

meter' :: forall m. Component m => m Unit -> m Unit
meter' = el' "meter"

optgroup' :: forall m. Component m => m Unit -> m Unit
optgroup' = el' "optgroup"

option' :: forall m. Component m => m Unit -> m Unit
option' = el' "option"

output' :: forall m. Component m => m Unit -> m Unit
output' = el' "output"

progress' :: forall m. Component m => m Unit -> m Unit
progress' = el' "progress"

select' :: forall m. Component m => m Unit -> m Unit
select' = el' "sel'ect"

textarea' :: forall m. Component m => m Unit -> m Unit
textarea' = el' "textarea"

details' :: forall m. Component m => m Unit -> m Unit
details' = el' "details"

dialog' :: forall m. Component m => m Unit -> m Unit
dialog' = el' "dialog"

summary' :: forall m. Component m => m Unit -> m Unit
summary' = el' "summary"

slot' :: forall m. Component m => m Unit -> m Unit
slot' = el' "slot"

template' :: forall m. Component m => m Unit -> m Unit
template' = el' "template"
