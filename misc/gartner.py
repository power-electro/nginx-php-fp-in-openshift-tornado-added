#!/opt/jython/jython
import sys, os
from time import sleep
home=os.environ['OPENSHIFT_HOMEDIR']
# jarpath = '/usr/share/java/htmlunit/' #path the jar files to import
jarpath =home+ '/app-root/runtime/srv/htmlunit/lib' #path the jar files to import
os.environ['CLASSPATH']=+home+'/app-root/runtime/srv/htmlunit/lib/'+':'+os.environ['CLASSPATH']
jars = ['apache-mime4j-0.6.jar','commons-codec-1.4.jar',
    'commons-collections-3.2.1.jar','commons-io-1.4.jar',
    'commons-lang-2.4.jar','commons-logging-1.1.1.jar',
    'cssparser-0.9.5.jar','htmlunit-2.8.jar',
    'htmlunit-core-js-2.8.jar','httpclient-4.0.1.jar',
    'httpcore-4.0.1.jar','httpmime-4.0.1.jar',
    'nekohtml-1.9.14.jar','sac-1.3.jar',
    'serializer-2.7.1.jar','xalan-2.7.1.jar',
    'xercesImpl-2.9.1.jar','xml-apis-1.3.04.jar'] #a list of jars

def loadjars(): #appends jars to jython path
    for jar in jars:
        print(jarpath+jar+'\n')
        container = jarpath+jar
        sys.path.append(container)

# loadjars()

import com.gargoylesoftware.htmlunit.WebClient as WebClient

import com.gargoylesoftware.htmlunit.BrowserVersion as BrowserVersion


def main():
   try:webclient = WebClient(BrowserVersion.FIREFOX_3_6) # creating a new webclient object.
   except:webclient = WebClient() # creating a new webclient object.
   url = "http://www.gartner.com/it/products/mq/mq_ms.jsp"
   url="http://goole.com"
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

def gotogoogle():
    """


    """
    webclient = WebClient() # creating a new webclient object.
    print('hello, I will visit Google')
    url='http://google.com'
    page = webclient.getPage(url)
    print(page)    

if __name__ == '__main__':
    gotogoogle()
    main()