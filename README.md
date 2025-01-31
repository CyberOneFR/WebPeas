<!-- # WebPeas

WebPeas is the Web verstion of linpeas for web-pentesting, that provides an overview of various aspects of a web application, including:

- CMS detection
- Endpoint enumeration with probing live urls
- CMS Scanning
- Subdomain enumeration with filtring HTTP and HTTPS
- Vulnerability scanning using nuclei
- Wayback scanning
- S3 bucket scanning
- GraphQL Discovery

## Instrallation
```
git clone https://github.com/UncleJ4ck/WebPeas
cd WebPeas
pip install -r requirements.txt
chmod +x ./auto.sh
```
### Docker

```docker
docker build -t webpeas:latest .
docker run --name peas webpeas
```

## To-Do

- [ ] adding smart contract checking
- [x] adding a dockerfile
- [ ] Fixing bugs


## Usage

To use WebPeas, run the ```./auto.sh <target>``` script and follow the prompts.

## Contributing

If you'd like to contribute to the development of WebPeas, please feel free to fork the repository and submit a pull request with your changes. All contributions are welcome and appreciated. -->

WIP