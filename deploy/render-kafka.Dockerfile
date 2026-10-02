FROM apache/kafka:3.7.0
COPY --chown=appuser:appuser deploy/render-kafka-entrypoint.sh /opt/kafka/render-kafka-entrypoint.sh
ENTRYPOINT ["/bin/bash", "/opt/kafka/render-kafka-entrypoint.sh"]
