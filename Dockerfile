FROM python:3.5-alpine
COPY ./requirements.txt /var/requirements.txt
RUN apk add --no-cache --virtual .build-deps  \
		gcc \
		libc-dev \
		linux-headers \
		freetds-dev \
    && pip3 install -r /var/requirements.txt \
    && find /usr/local -depth \
		\( \
		    \( -type d -a -name test -o -name tests \) \
		    -o \
		    \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		\) -exec rm -rf '{}' + \
	&& runDeps="$( \
		scanelf --needed --nobanner --recursive /usr/local \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)" \
	&& apk add --virtual .python-rundeps $runDeps \
    && apk del .build-deps