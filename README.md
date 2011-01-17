# Big Screen #
Big Screen is a self-hosted web application that helps manage your locally stored movie collection. It recognizes bizzarely-named movie files and directories and queries IMDB for their proper titles and other information. It then provides a simple, sortable web page for your collection where you can play any movie with a single click.

## Installation/Platform Compatibility ##
Big Screen has only been tested on Windows-32bit. You need the following before you can install the app:
- Ruby 1.9.2
- Rails 2.3.8 (other 2.x versions might work too)
- sqlite3 and the sqlite3 gem
- mongrel gem version 1.2.0 or greater (can be installed using 'gem install mongrel --pre') (You could use an alternative rails server if you like.)
Once you have installed the above, simply download the app and unzip the folder anywhere. Then cd into Big Screen's home directory and run 'rake db:schema:load RAILS_ENV=production'

### Usage ###
- Change the appropriate settings in config/config_production.yml
- To load all your movies into the app, you need to 'cd' into the app's home directory and run 'rake batch_parse RAILS_ENV=production'. The first time, this will run for a long time (about 10 seconds per movie, depending on your spces) because the app takes md5sums of every movie file so it doesn't get confused when you rename and move around movies. However, all following runs will be reasonably fast.
- To keep your collection up to date, you could do something like use Windows Scheduler to run the above rake task every night. That way, newly added movies will automatically get tracked.
- Run bin/run_prod_server.vbs (or start the rails server of your choice in production mode.)
- Open the app's homepage (for example http://localhost:3333) in your browser.

## Caveats ##
- Unicode filename support. Believe me, I tried, but gave up for now on Ruby/Windows unicode support. Filenames with characters in [Windows-1252 character encoding](http://en.wikipedia.org/wiki/Windows-1252) like "é" will still work though, but characters like '我' won't.

## TODO/Contributions ##
The project is still at a pretty raw stage, but I will be actively adding new features, such as search functionality, better filename parsing, and support for other OSes. Of course any contributions would be very welcomed.

## License ##
Copyright (c) 2010 by [Suan-Aik Yeo](mailto:yeosuanaik@gmail.com)
This is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation.

## Help ##
- Source project page:                    http://github.com/suan/big_screen
- Report a bug/Request a feature:         http://github.com/suan/big_screen/issues
- [Give feedback/Contact me (Suan-Aik Yeo)](mailto:yeosuanaik@gmail.com)
