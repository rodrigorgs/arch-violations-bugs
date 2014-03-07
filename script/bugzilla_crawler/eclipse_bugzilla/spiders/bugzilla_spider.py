from scrapy.spider import BaseSpider
from scrapy.contrib.spiders import Rule
from scrapy.contrib.linkextractors.sgml import SgmlLinkExtractor

class BugzillaSpider(BaseSpider):
	name = "bugzilla"
	start_urls = [x.strip() for x in list(open("urls-to-download", "r"))]
	rules = (
	Rule(SgmlLinkExtractor(allow=(), deny=(), allow_domains=(), deny_domains=(), deny_extensions=None, restrict_xpaths=(), tags=('a', 'area'), attrs=('href'), canonicalize=True, unique=True, process_value=None))
	)

	def parse(self, response):
		prefix, bug = response.url.split("id=")
		kind = prefix.find("show_bug") != -1 and "bug" or "history"
		open("downloads/" + kind + "-" + bug, "w").write(response.body)
		
