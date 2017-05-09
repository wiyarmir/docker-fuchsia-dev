FROM wiyarmir/fuchsia

ENV COMMIT_SHA af1dd921842718e4

RUN cd fuchsia/apps/sysui && \
    git checkout ${COMMIT_SHA}
CMD cd fuchsia/apps/sysui/armadillo && flutter build apk --release
