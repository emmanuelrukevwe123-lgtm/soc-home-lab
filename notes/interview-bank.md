# Interview answer bank

Answers built from things that actually happened in my lab.

## An alert should have fired but didn't. How do you troubleshoot it?

I follow the log through the pipeline one hop at a time, testing each one instead of guessing:

1. **Source:** did the event get logged? I checked auth.log on the server.
2. **Collection:** is the agent reading that log? Mine only read journald, so I added auth.log.
3. **Connection:** is the agent connected? I checked the agent state file.
4. **Detection:** does the rule match? Wazuh's Ruleset Test confirmed rule 5710 fired on the raw line.
5. **Shipping and storage:** the alert was in alerts.json, and the daily index had documents.
6. **Search:** is the dashboard looking at the right time? The root cause was the SIEM server's clock running 1 hour ahead.

## Why does time synchronisation matter in a SOC?

- **Correlation:** investigations line up events from many systems into one timeline.
- **Detection:** rules count events in time windows, such as 8 failed logins in 2 minutes.
- **Evidence:** inaccurate timestamps weaken incident reports and legal cases.
- **Authentication and compliance:** Kerberos fails beyond 5 minutes of skew, and PCI DSS 10.6 requires time sync.
- **In my lab:** alerts were stored but invisible because the SIEM server was 1 hour ahead.

## What is a stateful firewall?

It tracks each allowed connection in a state table, so I only allow the direction that starts the conversation and replies are allowed automatically. That's how a DMZ server can answer requests but never start a connection into the internal network. AWS security groups and Azure NSGs are stateful; AWS network ACLs are stateless.

## Why put web apps in a DMZ?

They face attackers, so they sit in a low-trust buffer zone. Firewall rules let them reply to requests and fetch updates, but not start connections into internal zones. If one is compromised, the attacker is contained. In my lab, the DMZ server can reach only Wazuh's agent ports and the internet on 80/443.
