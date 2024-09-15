version: '3.7'

services:
  db:
    image: arminc/clair-db:latest
    volumes:
      - clair-db-volume:/var/lib/postgresql/clair
    ports:
      - "5432:5432"
    networks:
      clair-network:
        aliases:
          - postgres

  clair:
    image: arminc/clair-local-scan:latest
    depends_on:
      - db
    ports:
      - "6060:6060"
    networks:
      clair-network:
        aliases:
          - clair

  clair-scanner:
    image: clair-scanner
    command: ["/bin/sh", "-c", "until curl -s http://clair:6060; do sleep 1; done && ./clair-scanner --ip '${HOSTNAME:-}' --verbose ubuntu:21.10"]
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - "9279:9279"
    depends_on:
      - clair
    networks:
      clair-network:
        aliases:
          - clair-scanner

networks:
  clair-network:
    driver: bridge

volumes:
  clair-db-volume:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: 'C:\Users\tauan\desktop\docker'
