# Grafana Module
Grafana is a popular, open-source platform for data visualization and monitoring. It allows users to query, visualize, and understand their metrics, logs, and traces from various data sources, creating interactive dashboards for analysis and alerting. Essentially, Grafana helps turn raw data into actionable insights through customizable charts, graphs, and other visualizations.

## Getting Started
Setting the following...
```
megacorp.services.grafana = {
  enable = true;
}
```
Will:
- Install Grafana
- Install/configure Nginx to proxy requests to the Grafana service
- Make Grafana available locally over http://localhost

## Default Credenials
Username: admin
Password: admin

## Accessing HTTP web interface over a network
[See here](https://github.com/rapture-mc/mgc-nixos/tree/main/docs/making-services-accessible-via-network.md)

## Encrypting HTTP with TLS (HTTPS)
[See here](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/_shared/nginx)
