# Scraping Banco do Brasil

## Running it

Save a copy of the credentials file, replacing values with your account information and your 8-digit password.

```console
$ cp config/credentials.yml.example config/credentials.yml
```

To scrape your personal account, run the `scraper` executable. This will save the current state of your account in the `data` folder.

```console
$ ./scraper
```

## License

[MIT](https://tldrlegal.com/license/mit-license). Check [LICENSE](LICENSE) file for full disclosure.
