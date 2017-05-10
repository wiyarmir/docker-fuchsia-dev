FROM cogniteev/oracle-java:java8

ARG VCS_REF
ARG BUILD_DATE

LABEL org.label-schema.build-date=$BUILD_DATE \
	  org.label-schema.vcs-ref=$VCS_REF \
	  org.label-schema.vcs-url="e.g. https://github.com/wiyarmir/docker-fuchsia-dev" \
	  org.label-schema.schema-version="1.0"
          
### START OF CONFIG ###

ENV FLUTTER_BRANCH alpha
ENV GRADLE_VER gradle-3.3
ENV ANDROID_API_LEVELS android-25
ENV ANDROID_BUILD_TOOLS_VERSION 25.0.3
ENV ANDROID_SDK_FILENAME sdk-tools-linux-3859397.zip

### END OF CONFIG ###

ENV HOME /home/fuchsia
ENV GRADLE_DIST ${GRADLE_VER}-bin.zip
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/${ANDROID_SDK_FILENAME}
ENV ANDROID_HOME ${HOME}/android-sdk-linux

# General deps
RUN dpkg --add-architecture i386 
RUN apt-get update && apt-get install -y \
    build-essential                      \
    git                                  \
    curl                                 \
    zip                                  \
    unzip                                \
    lib32stdc++6                         \
    expect								 \
    libc6:i386 							 \
    libncurses5:i386					 \ 
    libstdc++6:i386 					 \
    lib32z1 
        
# Prepare user and workdir
RUN mkdir -p ${HOME}
RUN groupadd -r fuchsia && useradd -r -g fuchsia fuchsia
RUN chown fuchsia:fuchsia ${HOME}
WORKDIR ${HOME}
USER fuchsia
    
# Install Gradle
RUN wget -q https://services.gradle.org/distributions/${GRADLE_DIST} && \
    unzip ${GRADLE_DIST} 											 && \
    rm ${GRADLE_DIST} 
ENV PATH ${PATH}:${HOME}/${GRADLE_VER}/bin 

# Installs Android SDK
RUN mkdir -p ${ANDROID_HOME} 		 && \
    cd ${ANDROID_HOME}				 && \
    wget  -q ${ANDROID_SDK_URL} 	 && \
    unzip -q ${ANDROID_SDK_FILENAME} && \
    rm ${ANDROID_SDK_FILENAME} 
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

COPY accept-and-install-sdk.exp .
RUN ./accept-and-install-sdk.exp ${ANDROID_API_LEVELS} ${ANDROID_BUILD_TOOLS_VERSION}

# Install Flutter
RUN git clone -b ${FLUTTER_BRANCH} https://github.com/flutter/flutter.git
ENV PATH="${HOME}/flutter/bin:${PATH}"
RUN flutter doctor

# Get fuchsia
RUN mkdir fuchsia 		  && \
    cd fuchsia			  && \
    mkdir -p apps/modules && \
    mkdir -p lib 		  && \
    mkdir -p third_party 
RUN cd fuchsia/apps && \
    git clone https://github.com/fuchsia-mirror/sysui.git
RUN cd fuchsia/apps/modules && \
    git clone https://github.com/fuchsia-mirror/modules-common.git common
RUN cd fuchsia/lib && \
    git clone https://fuchsia.googlesource.com/widgets
RUN cd fuchsia/third_party && \
    git clone https://github.com/fuchsia-mirror/third_party-dart-pkg dart-pkg
