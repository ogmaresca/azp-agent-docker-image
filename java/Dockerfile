ARG AZP_AGENT_IMAGE_VERSION=v1
ARG AZP_AGENT_BASE_IMAGE=base

ARG DISTRO=ubuntu
ARG DISTRO_VERSION=18.04
ARG DISTRO_FRIENDLY=bionic

ARG ANT_VERSION=1.10.6
ARG CLOJURE_VERSION=2.9.1
ARG GRADLE_VERSION=5.5.1
ARG JDK_CURRENT_VERSION_MAJOR=12
ARG JDK_CURRENT_VERSION_MINOR=0.2
ARG JDK_LTS_VERSION_MAJOR=8
ARG JDK_LTS_VERSION=8u222
ARG MAVEN_VERSION=3.6.1
ARG SCALA_VERSION=2.13.0
ARG SBT_VERSION=1.2.8

FROM docker.io/openjdk:${JDK_CURRENT_VERSION_MAJOR}.${JDK_CURRENT_VERSION_MINOR}-jdk AS jdk_current_official
FROM docker.io/openjdk:${JDK_LTS_VERSION}-jdk AS jdk_lts_official

FROM docker.io/gradle:${GRADLE_VERSION}-jdk${JDK_CURRENT_VERSION_MAJOR} AS gradle_official

FROM docker.io/clojure:openjdk-${JDK_LTS_VERSION_MAJOR}-lein-${CLOJURE_VERSION} AS clojure_official

FROM docker.io/maven:${MAVEN_VERSION}-jdk-${JDK_CURRENT_VERSION_MAJOR} AS maven_official

FROM gmaresca/azure-pipeline-agent:${DISTRO}-${DISTRO_VERSION}-${AZP_AGENT_BASE_IMAGE}-${AZP_AGENT_IMAGE_VERSION} AS java

ARG JDK_CURRENT_VERSION_MAJOR=12
ARG JDK_CURRENT_VERSION_MINOR=0.2
ARG JDK_LTS_VERSION_MAJOR=8
ARG JDK_LTS_VERSION=8u222

COPY --from=jdk_current_official /usr/java/latest /usr/java/latest
COPY --from=jdk_lts_official /usr/local/openjdk-${JDK_LTS_VERSION_MAJOR} /usr/java/openjdk-${JDK_LTS_VERSION_MAJOR}

ENV JAVA_HOME /usr/java/latest
ENV PATH $PATH:$JAVA_HOME/bin

ENV java $JAVA_HOME/bin/java

FROM java AS scala

ARG SCALA_VERSION=2.13.0
RUN curl -fsL https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz | tar zxvf - -C /usr/local/bin

ENV PATH $PATH:/usr/local/bin/scala-${SCALA_VERSION}/bin

ENV scala /usr/local/bin/scala-${SCALA_VERSION}/bin/scala

FROM scala AS sbt

ARG SBT_VERSION=1.2.8
RUN curl -fsL https://sbt-downloads.cdnedge.bluemix.net/releases/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz | tar zxvf - -C /usr/local/bin

ENV PATH $PATH:/usr/local/bin/sbt/bin

ENV sbt /usr/local/bin/sbt/bin/sbt

FROM sbt AS ant

ARG ANT_VERSION=1.10.6
RUN curl -fsL https://www-us.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz | tar zxvf - -C /usr/local/bin

ENV PATH $PATH:/usr/local/bin/apache-ant-${ANT_VERSION}/bin

ENV ant /usr/local/bin/apache-ant-${ANT_VERSION}/bin/ant

FROM ant AS gradle

RUN apt-get update && apt-get install -y --no-install-recommends \
  fontconfig \
  mercurial \
  subversion

COPY --from=gradle_official /opt/gradle /opt/gradle

ENV GRADLE_HOME /opt/gradle

ENV gradle /usr/local/bin/gradle

RUN ln -s $GRADLE_HOME/bin/gradle $gradle

FROM gradle AS clojure

ARG CLOJURE_VERSION=2.9.1

COPY --from=clojure_official /usr/local/bin/lein /usr/local/bin/lein
COPY --from=clojure_official /usr/share/java/leiningen-${CLOJURE_VERSION}-standalone.jar /usr/share/java/leiningen-${CLOJURE_VERSION}-standalone.jar

RUN ln -s /usr/local/bin/lein /usr/local/bin/clojure

ENV clojure /usr/local/bin/lein
ENV lein /usr/local/bin/lein

FROM clojure AS maven

COPY --from=maven_official /usr/share/maven /usr/share/maven

ENV MAVEN_HOME /usr/share/maven

ENV PATH $PATH:$MAVEN_HOME/bin

RUN ln -s $MAVEN_HOME/bin/mvn $MAVEN_HOME/bin/maven

ENV maven $MAVEN_HOME/bin/maven
ENV mvn $MAVEN_HOME/bin/mvn

# Cleanup
FROM maven AS final
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /etc/apt/sources.list.d/*

