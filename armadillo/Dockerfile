FROM wiyarmir/fuchsia

ARG VCS_REF
ARG BUILD_DATE

LABEL org.label-schema.build-date=$BUILD_DATE \
	  org.label-schema.vcs-ref=$VCS_REF \
	  org.label-schema.vcs-url="e.g. https://github.com/wiyarmir/docker-fuchsia-dev" \
	  org.label-schema.schema-version="1.0"
	  
ENV COMMIT_SHA af1dd921842718e4

RUN cd fuchsia/apps/sysui && \
    git checkout ${COMMIT_SHA}
CMD cd fuchsia/apps/sysui/armadillo && flutter build apk --release
