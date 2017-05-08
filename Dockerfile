FROM cogniteev/oracle-java:java8

ENV HOME /home/fuchsia
ENV ANDROID_SDK_FILENAME sdk-tools-linux-3859397.zip
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/${ANDROID_SDK_FILENAME}
ENV ANDROID_API_LEVELS android-25
ENV ANDROID_BUILD_TOOLS_VERSION 25.0.3
ENV ANDROID_HOME ${HOME}/android-sdk-linux

# General deps
RUN apt-get update && apt-get install -y \
    build-essential                      \
    git                                  \
    curl                                 \
    zip                                  \
    unzip                                \
    lib32stdc++6                         \
    expect
    
# Installs i386 architecture required for running 32 bit Android tools
RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean
        
# Prepare user and workdir
RUN mkdir -p ${HOME}
RUN groupadd -r fuchsia && useradd -r -g fuchsia fuchsia
RUN chown fuchsia:fuchsia ${HOME}
WORKDIR ${HOME}
USER fuchsia
    
# Install Gradle
RUN wget -q https://services.gradle.org/distributions/gradle-3.3-bin.zip
RUN unzip gradle-3.3-bin.zip
ENV PATH ${PATH}:${HOME}/gradle-3.3/bin
RUN gradle -v

# Installs Android SDK
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
RUN mkdir -p ${ANDROID_HOME} && \
    cd ${ANDROID_HOME} && \
    wget  -q ${ANDROID_SDK_URL} && \
    unzip -q ${ANDROID_SDK_FILENAME} && \
    rm ${ANDROID_SDK_FILENAME} 

COPY accept-and-install-sdk.exp .
RUN ./accept-and-install-sdk.exp ${ANDROID_API_LEVELS} ${ANDROID_BUILD_TOOLS_VERSION}

# Install Flutter
RUN git clone -b alpha https://github.com/flutter/flutter.git
ENV PATH="${HOME}/flutter/bin:${PATH}"
RUN flutter doctor

# Get fuchsia
RUN mkdir fuchsia && \
    cd fuchsia && \
    mkdir -p apps/modules && \
    mkdir -p lib && \
    mkdir -p third_party 
RUN cd fuchsia/apps && \
    git clone https://github.com/fuchsia-mirror/sysui.git
RUN cd fuchsia/apps/modules && \
    git clone https://github.com/fuchsia-mirror/modules-common.git common
RUN cd fuchsia/lib && \
    git clone https://fuchsia.googlesource.com/widgets
RUN cd fuchsia/third_party && \
    git clone https://github.com/fuchsia-mirror/third_party-dart-pkg dart-pkg
RUN cd fuchsia/third_party

# Build Armadillo
RUN cd fuchsia/apps/sysui/armadillo && flutter build apk --release