Gumshoe
-------

Gumshoe is a Rails-based application for searching metadata from disk images. It relies on [Blacklight](http://projectblacklight.org/), [Solr](http://lucene.apache.org/), and [fiwalk](http://domex.nps.edu/deep/Fiwalk.html). 

Dependencies
============

In addition to Ruby, rubygems, and Rails, you'll need to install fiwalk. If you're on a Mac and use [Homebrew](http://github.com/mxcl/homebrew), you can install it using `brew install fiwalk`.

Getting Started
===============

To get started, you'll need to to get a git clone of the codebase:

	$ git clone git://github.com/anarchivist/gumshoe.git

Then pull in the Solr/Jetty bundle:

	$ git submodule init
	$ git submodule update

Get the application's gems:

	$ bundle install
	
Start up Solr:

	$ cd jetty
	$ java -jar start.jar

Download the sample image:

	$ rake app:image:download

Extract and index the metadata from the sample image:

	$ rake app:index:image FILE=images/ubnist1.casper-rw.gen2.aff
	
Start Gumshoe:

	$ script/server

Open your browser to http://localhost:3000/ and start playing!