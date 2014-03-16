## Home

https://github.com/bcurren/freshbooks.rb

## Todo

Please send me a message if you are interested in contributing. Here is a quick overview of some things I'd like to add to the gem:
* Merge in forked versions of this gem. (Any idea what forks are worth while?)
* Provide a way to retrieve the error message with actions beside list are called.
* Make ListProxy optional on list actions. Some people have valid reason to deal with pagination.
* Add OAuth.
* Add WebHooks.
* More tests, including integration tests.
* Write some documentation and examples.
* Launch an official 3.0 (maybe call it 4.0) version of the gem.
* Post the official version to rubygems.
* Ensure rubygems aren't required for this gem. 

## About

FreshBooks.rb is a Ruby interface to the FreshBooks API. It exposes easy-to-use classes and methods for interacting with your FreshBooks account.

***NOTE:** These examples are out of date and need to be updated. I will be writing documentation for all the updates soon and will be pushing the changes to rubyforge in the near future.*

## Examples

Initialization:

    FreshBooks::Base.establish_connection('sample.freshbooks.com', 'mytoken')

Updating a client name:

    clients = FreshBooks::Client.list
    client = clients[0]
    client.first_name = 'Suzy'
    client.update

Updating an invoice:

    invoice = FreshBooks::Invoice.get(4)
    invoice.lines[0].quantity += 1
    invoice.update

Creating a new item

    item = FreshBooks::Item.new
    item.name = 'A sample item'
    item.create

## License

This work is distributed under the MIT License. Use/modify the code however you like.

## Download

`sudo gem install freshbooks.rb`

## Credits

FreshBooks.rb is written and maintained by [Ben Curren](https://github.com/bcurren) at [Outright.com](http://outright.com/). [Ben Vinegar](http://benv.ca/) was the original developer and we have taken over maintenance of the gem from now on.

