FROM ubuntu:latest

RUN apt update 
RUN apt install -y git 
RUN apt install -y make
RUN apt install -y perl 
RUN apt install -y ruby-full
RUN apt install -y golang-go
RUN apt install -y python3
RUN apt install -y pipx
RUN apt install -y python3-pip 
RUN apt install -y python3-venv
RUN apt upgrade -y

RUN mkdir /webpeas
WORKDIR /webpeas

RUN go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
RUN go install github.com/tomnomnom/httprobe@latest > /dev/null
RUN go install github.com/projectdiscovery/httpx/cmd/httpx@latest > /dev/null
RUN go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest > /dev/null
RUN go install github.com/tomnomnom/waybackurls@latest > /dev/null
RUN go install github.com/sa7mon/s3scanner@latest > /dev/null
ENV PATH="$PATH:/root/go/bin"

RUN gem install nokogiri wpscan

COPY ./dirsearch /webpeas/dirsearch
RUN python3 -m venv /webpeas/dirsearch/venv
RUN /webpeas/dirsearch/venv/bin/pip install -r /webpeas/dirsearch/requirements.txt
RUN ln -s /webpeas/dirsearch/venv/bin/python3 /usr/local/bin/dirsearch

COPY ./CMSeeK /webpeas/CMSeeK
RUN python3 -m venv /webpeas/CMSeeK/venv
RUN /webpeas/CMSeeK/venv/bin/pip install -r /webpeas/CMSeeK/requirements.txt
RUN ln -s /webpeas/CMSeeK/venv/bin/python3 /usr/local/bin/cmseek

COPY ./auto.sh /webpeas/auto.sh
COPY ./graph.py /webpeas/graph.py
COPY ./joomscan /webpeas/joomscan

RUN chmod +x /webpeas/auto.sh

CMD [ "sh", "./auto.sh", "https://2-ez.f"]