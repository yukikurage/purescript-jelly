module Jelly.Element where

import Prelude

import Jelly.Component (Component, el, el', elVoid, elVoid')
import Jelly.Prop (Prop)

html :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
html = el "html"

base :: forall m. Monad m => Array (Prop m) -> Component m
base = elVoid "base"

head :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
head = el "head"

link :: forall m. Monad m => Array (Prop m) -> Component m
link = elVoid "link"

meta :: forall m. Monad m => Array (Prop m) -> Component m
meta = elVoid "meta"

style :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
style = el "style"

title :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
title = el "title"

body :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
body = el "body"

address :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
address = el "address"

article :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
article = el "article"

aside :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
aside = el "aside"

footer :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
footer = el "footer"

header :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
header = el "header"

h1 :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
h1 = el "h1"

h2 :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
h2 = el "h2"

h3 :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
h3 = el "h3"

h4 :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
h4 = el "h4"

h5 :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
h5 = el "h5"

h6 :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
h6 = el "h6"

main :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
main = el "main"

nav :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
nav = el "nav"

section :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
section = el "section"

blockquote :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
blockquote = el "blockquote"

dd :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
dd = el "dd"

div :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
div = el "div"

dl :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
dl = el "dl"

dt :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
dt = el "dt"

figcaption :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
figcaption = el "figcaption"

figure :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
figure = el "figure"

hr :: forall m. Monad m => Array (Prop m) -> Component m
hr = elVoid "hr"

li :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
li = el "li"

menu :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
menu = el "menu"

ol :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
ol = el "ol"

p :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
p = el "p"

pre :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
pre = el "pre"

ul :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
ul = el "ul"

a :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
a = el "a"

abbr :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
abbr = el "abbr"

b :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
b = el "b"

bdi :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
bdi = el "bdi"

bdo :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
bdo = el "bdo"

br :: forall m. Monad m => Array (Prop m) -> Component m
br = elVoid "br"

cite :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
cite = el "cite"

code :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
code = el "code"

data_ :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
data_ = el "data"

dfn :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
dfn = el "dfn"

em :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
em = el "em"

i :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
i = el "i"

kbd :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
kbd = el "kbd"

mark :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
mark = el "mark"

q :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
q = el "q"

rp :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
rp = el "rp"

rt :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
rt = el "rt"

ruby :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
ruby = el "ruby"

s :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
s = el "s"

samp :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
samp = el "samp"

small :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
small = el "small"

span :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
span = el "span"

strong :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
strong = el "strong"

sub :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
sub = el "sub"

sup :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
sup = el "sup"

time :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
time = el "time"

u :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
u = el "u"

var :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
var = el "var"

wbr :: forall m. Monad m => Array (Prop m) -> Component m
wbr = elVoid "wbr"

area :: forall m. Monad m => Array (Prop m) -> Component m
area = elVoid "area"

audio :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
audio = el "audio"

img :: forall m. Monad m => Array (Prop m) -> Component m
img = elVoid "img"

map :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
map = el "map"

track :: forall m. Monad m => Array (Prop m) -> Component m
track = elVoid "track"

video :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
video = el "video"

embed :: forall m. Monad m => Array (Prop m) -> Component m
embed = elVoid "embed"

iframe :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
iframe = el "iframe"

object :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
object = el "object"

picture :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
picture = el "picture"

portal :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
portal = el "portal"

source :: forall m. Monad m => Array (Prop m) -> Component m
source = elVoid "source"

svg :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
svg = el "svg"

math :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
math = el "math"

canvas :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
canvas = el "canvas"

noscript :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
noscript = el "noscript"

script :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
script = el "script"

del :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
del = el "del"

ins :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
ins = el "ins"

caption :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
caption = el "caption"

col :: forall m. Monad m => Array (Prop m) -> Component m
col = elVoid "col"

colgroup :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
colgroup = el "colgroup"

table :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
table = el "table"

tbody :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
tbody = el "tbody"

td :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
td = el "td"

tfoot :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
tfoot = el "tfoot"

th :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
th = el "th"

thead :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
thead = el "thead"

tr :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
tr = el "tr"

button :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
button = el "button"

datalist :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
datalist = el "datalist"

fieldset :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
fieldset = el "fieldset"

form :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
form = el "form"

input :: forall m. Monad m => Array (Prop m) -> Component m
input = elVoid "input"

label :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
label = el "label"

legend :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
legend = el "legend"

meter :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
meter = el "meter"

optgroup :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
optgroup = el "optgroup"

option :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
option = el "option"

output :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
output = el "output"

progress :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
progress = el "progress"

select :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
select = el "select"

textarea :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
textarea = el "textarea"

details :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
details = el "details"

dialog :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
dialog = el "dialog"

summary :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
summary = el "summary"

slot :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
slot = el "slot"

template :: forall m. Monad m => Array (Prop m) -> Component m -> Component m
template = el "template"

html' :: forall m. Monad m => Component m -> Component m
html' = el' "html"

head' :: forall m. Monad m => Component m -> Component m
head' = el' "head"

title' :: forall m. Monad m => Component m -> Component m
title' = el' "title"

base' :: forall m. Monad m => Component m -> Component m
base' = el' "base"

link' :: forall m. Monad m => Component m -> Component m
link' = el' "link"

meta' :: forall m. Monad m => Component m -> Component m
meta' = el' "meta"

style' :: forall m. Monad m => Component m -> Component m
style' = el' "style"

body' :: forall m. Monad m => Component m -> Component m
body' = el' "body"

address' :: forall m. Monad m => Component m -> Component m
address' = el' "address"

article' :: forall m. Monad m => Component m -> Component m
article' = el' "article"

aside' :: forall m. Monad m => Component m -> Component m
aside' = el' "aside"

footer' :: forall m. Monad m => Component m -> Component m
footer' = el' "footer"

header' :: forall m. Monad m => Component m -> Component m
header' = el' "header"

h1' :: forall m. Monad m => Component m -> Component m
h1' = el' "h1"

h2' :: forall m. Monad m => Component m -> Component m
h2' = el' "h2"

h3' :: forall m. Monad m => Component m -> Component m
h3' = el' "h3"

h4' :: forall m. Monad m => Component m -> Component m
h4' = el' "h4"

h5' :: forall m. Monad m => Component m -> Component m
h5' = el' "h5"

h6' :: forall m. Monad m => Component m -> Component m
h6' = el' "h6"

main' :: forall m. Monad m => Component m -> Component m
main' = el' "main"

nav' :: forall m. Monad m => Component m -> Component m
nav' = el' "nav"

section' :: forall m. Monad m => Component m -> Component m
section' = el' "section"

blockquote' :: forall m. Monad m => Component m -> Component m
blockquote' = el' "blockquote"

dd' :: forall m. Monad m => Component m -> Component m
dd' = el' "dd"

div' :: forall m. Monad m => Component m -> Component m
div' = el' "div"

dl' :: forall m. Monad m => Component m -> Component m
dl' = el' "dl"

dt' :: forall m. Monad m => Component m -> Component m
dt' = el' "dt"

figcaption' :: forall m. Monad m => Component m -> Component m
figcaption' = el' "figcaption"

figure' :: forall m. Monad m => Component m -> Component m
figure' = el' "figure"

hr' :: forall m. Monad m => Component m
hr' = elVoid' "hr"

li' :: forall m. Monad m => Component m -> Component m
li' = el' "li"

menu' :: forall m. Monad m => Component m -> Component m
menu' = el' "menu"

ol' :: forall m. Monad m => Component m -> Component m
ol' = el' "ol"

p' :: forall m. Monad m => Component m -> Component m
p' = el' "p"

pre' :: forall m. Monad m => Component m -> Component m
pre' = el' "pre"

ul' :: forall m. Monad m => Component m -> Component m
ul' = el' "ul"

a' :: forall m. Monad m => Component m -> Component m
a' = el' "a"

abbr' :: forall m. Monad m => Component m -> Component m
abbr' = el' "abbr"

b' :: forall m. Monad m => Component m -> Component m
b' = el' "b"

bdi' :: forall m. Monad m => Component m -> Component m
bdi' = el' "bdi"

bdo' :: forall m. Monad m => Component m -> Component m
bdo' = el' "bdo"

br' :: forall m. Monad m => Component m
br' = elVoid' "br"

cite' :: forall m. Monad m => Component m -> Component m
cite' = el' "cite"

code' :: forall m. Monad m => Component m -> Component m
code' = el' "code"

data_' :: forall m. Monad m => Component m -> Component m
data_' = el' "data"

dfn' :: forall m. Monad m => Component m -> Component m
dfn' = el' "dfn"

em' :: forall m. Monad m => Component m -> Component m
em' = el' "em"

i' :: forall m. Monad m => Component m -> Component m
i' = el' "i"

kbd' :: forall m. Monad m => Component m -> Component m
kbd' = el' "kbd"

mark' :: forall m. Monad m => Component m -> Component m
mark' = el' "mark"

q' :: forall m. Monad m => Component m -> Component m
q' = el' "q"

rp' :: forall m. Monad m => Component m -> Component m
rp' = el' "rp"

rt' :: forall m. Monad m => Component m -> Component m
rt' = el' "rt"

ruby' :: forall m. Monad m => Component m -> Component m
ruby' = el' "ruby"

s' :: forall m. Monad m => Component m -> Component m
s' = el' "s"

samp' :: forall m. Monad m => Component m -> Component m
samp' = el' "samp"

small' :: forall m. Monad m => Component m -> Component m
small' = el' "small"

span' :: forall m. Monad m => Component m -> Component m
span' = el' "span"

strong' :: forall m. Monad m => Component m -> Component m
strong' = el' "strong"

sub' :: forall m. Monad m => Component m -> Component m
sub' = el' "sub"

sup' :: forall m. Monad m => Component m -> Component m
sup' = el' "sup"

time' :: forall m. Monad m => Component m -> Component m
time' = el' "time"

u' :: forall m. Monad m => Component m -> Component m
u' = el' "u"

var' :: forall m. Monad m => Component m -> Component m
var' = el' "var"

wbr' :: forall m. Monad m => Component m
wbr' = elVoid' "wbr"

area' :: forall m. Monad m => Component m
area' = elVoid' "area"

audio' :: forall m. Monad m => Component m -> Component m
audio' = el' "audio"

img' :: forall m. Monad m => Component m
img' = elVoid' "img"

map' :: forall m. Monad m => Component m -> Component m
map' = el' "map"

track' :: forall m. Monad m => Component m
track' = elVoid' "track"

video' :: forall m. Monad m => Component m -> Component m
video' = el' "video"

embed' :: forall m. Monad m => Component m
embed' = elVoid' "embed"

iframe' :: forall m. Monad m => Component m -> Component m
iframe' = el' "iframe"

object' :: forall m. Monad m => Component m -> Component m
object' = el' "object"

picture' :: forall m. Monad m => Component m -> Component m
picture' = el' "picture"

portal' :: forall m. Monad m => Component m -> Component m
portal' = el' "portal"

source' :: forall m. Monad m => Component m
source' = elVoid' "source"

svg' :: forall m. Monad m => Component m -> Component m
svg' = el' "svg"

math' :: forall m. Monad m => Component m -> Component m
math' = el' "math"

canvas' :: forall m. Monad m => Component m -> Component m
canvas' = el' "canvas"

noscript' :: forall m. Monad m => Component m -> Component m
noscript' = el' "noscript"

script' :: forall m. Monad m => Component m -> Component m
script' = el' "script"

del'' :: forall m. Monad m => Component m -> Component m
del'' = el' "del'"

ins' :: forall m. Monad m => Component m -> Component m
ins' = el' "ins"

caption' :: forall m. Monad m => Component m -> Component m
caption' = el' "caption"

col' :: forall m. Monad m => Component m
col' = elVoid' "col"

colgroup' :: forall m. Monad m => Component m -> Component m
colgroup' = el' "colgroup"

table' :: forall m. Monad m => Component m -> Component m
table' = el' "table"

tbody' :: forall m. Monad m => Component m -> Component m
tbody' = el' "tbody"

td' :: forall m. Monad m => Component m -> Component m
td' = el' "td"

tfoot' :: forall m. Monad m => Component m -> Component m
tfoot' = el' "tfoot"

th' :: forall m. Monad m => Component m -> Component m
th' = el' "th"

thead' :: forall m. Monad m => Component m -> Component m
thead' = el' "thead"

tr' :: forall m. Monad m => Component m -> Component m
tr' = el' "tr"

button' :: forall m. Monad m => Component m -> Component m
button' = el' "button"

datalist' :: forall m. Monad m => Component m -> Component m
datalist' = el' "datalist"

fiel'dset' :: forall m. Monad m => Component m -> Component m
fiel'dset' = el' "fiel'dset"

form' :: forall m. Monad m => Component m -> Component m
form' = el' "form"

input' :: forall m. Monad m => Component m
input' = elVoid' "input"

label'' :: forall m. Monad m => Component m -> Component m
label'' = el' "label'"

legend' :: forall m. Monad m => Component m -> Component m
legend' = el' "legend"

meter' :: forall m. Monad m => Component m -> Component m
meter' = el' "meter"

optgroup' :: forall m. Monad m => Component m -> Component m
optgroup' = el' "optgroup"

option' :: forall m. Monad m => Component m -> Component m
option' = el' "option"

output' :: forall m. Monad m => Component m -> Component m
output' = el' "output"

progress' :: forall m. Monad m => Component m -> Component m
progress' = el' "progress"

select' :: forall m. Monad m => Component m -> Component m
select' = el' "sel'ect"

textarea' :: forall m. Monad m => Component m -> Component m
textarea' = el' "textarea"

details' :: forall m. Monad m => Component m -> Component m
details' = el' "details"

dialog' :: forall m. Monad m => Component m -> Component m
dialog' = el' "dialog"

summary' :: forall m. Monad m => Component m -> Component m
summary' = el' "summary"

slot' :: forall m. Monad m => Component m -> Component m
slot' = el' "slot"

template' :: forall m. Monad m => Component m -> Component m
template' = el' "template"
