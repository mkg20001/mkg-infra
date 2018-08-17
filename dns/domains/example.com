# Records

# Normal A/AAAA
#<type>	<domain><value>	<use-cloudflare>
A	@	1.2.3.4	true
AAAA	@	::2	true

# TXT
TXT	@	some-value

# CNAME
# will cname to $DOMAIN
CNAME	sub	@	true
# will cname to sub.$DOMAIN
CNAME	sub2	sub

# MX
MX	@	10	mail.provider.com

# DNSLINK create IPFS dnslink txts
# creates TXT dnslink=/ipfs/HASH
DNSLINK	@	/ipfs/HASH

# INCLUDE allows including other files
INCLUDE	domain-verifiction-txts
INCLUDE	global-mail-settings

# CLINK copies records from one domain to another (that way you can CNAME one domain to multiple other domains for load balancing)
CLINK	lb-test	server1
CLINK	lb-test	server2
