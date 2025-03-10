# getlinks
a simple tool to show links (A tag's href) in a html file or url

It's intented to get a list of all links in an html file or url in order to serve as input text to wget for download

So it's pretty simple, just parse the html content to get all A tags and show the href attribute, in order to make it easy to handle the output there're some options to include full path link and to filter the output links with regular expression

# dependencies

* tcl with a bunch of packages

you can make it an executable without dependecies if you want

# install

just copy the script to some place 

# use

$ tclsh getlinks -?

