import com.gargoylesoftware.htmlunit.WebClient as WebClient

import com.gargoylesoftware.htmlunit.BrowserVersion as BrowserVersion


def main():
   webclient = WebClient(BrowserVersion.FIREFOX_3_6) # creating a new webclient object.
   url = "http://www.gartner.com/it/products/mq/mq_ms.jsp"
   page = webclient.getPage(url) # getting the url
   articles = page.getByXPath("//table[@id='mqtable']//tr/td/a") # getting all the hyperlinks
   for article in articles:
        print "Clicking on:", article
        subpage = article.click() # click on the article link13
        title = subpage.getByXPath("//div[@class='title']") # get title

        summary = subpage.getByXPath("//div[@class='summary']") # get summary
        if len(title) > 0 and len(summary) > 0:
             print "Title:", title[0].asText()

             print "Summary:", summary[0].asText()
if __name__ == '__main__':
        main()