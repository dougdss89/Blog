#cria imagem spark

#imagem do SO como base
FROM python:3.10-bullseye as spark-base

#atualiza SO e instala os pacotes
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
		sudo \
		curl \
		vim \
		nano \
		unzip \
		rsync \
		openjdk-11-jdk \
		build-essential \
		software-properties-common \
		ssh && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

#variaveis de ambiente
ENV SPARK_HOME=${SPARK_HOME:-"/opt/spark"}
ENV HADOOP_HOME=${HADOOP_HOME:-"/opt/hadoop"}

#criando as pastas
#criando as pastas do hadoop e spark utilizando as variáveis de ambiente
#WORKDIR é o workdirectory para os comandos run e etc
RUN mkdir -p ${HADOOP_HOME} && mkdir -p ${SPARK_HOME}
WORKDIR ${SPARK_HOME}

#Baixando os binários do SPARK
RUN curl https://dlcdn.apache.org/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz -o spark-3.5.0-bin-hadoop3.tgz \
&& tar xvfz spark-3.5.0-bin-hadoop3.tgz --directory /opt/spark --strip-components 1\
&& rm -rf spark-3.5.0-bin-hadoop3.tgz

#baixado o spark - configurar o ambiente pyspark
#ambiente pyspark
#puxando da versão 3.10 do python como spark-base
FROM spark-base as pyspark

#instalando as dependencias Python
COPY requirements/requirements.txt .
RUN pip3 install -r requirements.txt

#variaveis de ambiente
ENV PATH="/opt/spark/sbin:/opt/spark/bin:${PATH}"
ENV SPARK_HOME="/opt/spark"
ENV SPARK_MASTER="spark://spark-master:7077"
ENV SPARK_MASTER_HOST spark-master
ENV SPARK_MASTER_PORT 7077
ENV PYSPARK_PYTHON python3

#copia os arquivos da config para a imagem docker
COPY conf/spark-defaults.conf "$SPARK_HOME/conf"

#permissao
RUN chmod u+x /opt/spark/sbin/ ** && \
    chmod u+x /opt/spark/bin/*

#PYTHON PATH
ENV PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH

#copia os serviços do entrypoint para a imagem docker
COPY entrypoint.sh .

#corrige privilégio
RUN chmod +x entrypoint.sh

#executa o script ao iniciar o container
ENTRYPOINT ["./entrypoint.sh"]

