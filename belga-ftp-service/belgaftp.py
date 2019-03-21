from ftplib import FTP
import xml.etree.ElementTree as etree
import io
from datetime import datetime as dt
import pytz


class BelgaFTPService:

    def __init__(self):
        self.belga_host = "ftp.belga.be"

    def get_repository(self, username, password):
        ftp_conn = FTP(host=self.belga_host, user=username, passwd=password)
        print(ftp_conn.retrlines('LIST'))
        ftp_conn.quit()

    def check_document_existence(self, document_name, username, password):
        ftp_conn = FTP(host=self.belga_host, user=username, passwd=password)
        files = ftp_conn.nlst()
        ftp_conn.quit()
        if files and document_name in files:
            return True
        return False

    def upload_file(self, filename, username, password, data=None):
        if not str(filename).endswith(".xml"):
            filename = f"{filename}.xml"
        ftp_conn = FTP(host=self.belga_host, user=username, passwd=password)
        if data:
            ftp_conn.storlines(f"STOR {filename}", io.BytesIO(data))
        else:
            ftp_conn.storlines(f"STOR {filename}", open(filename, 'rb'))
        ftp_conn.quit()

    def delete_file(self, filename, username, password):
        ftp_conn = FTP(host=self.belga_host, user=username, passwd=password)
        ftp_conn.delete(filename)
        ftp_conn.quit()

    def normalize_id(self, pub_id):
        if len(str(pub_id)) == 13:
            return int(pub_id)
        padding_str = ""
        for i in range(12 - len(str(pub_id))):
            padding_str += "0"
        return int(f"2{padding_str}{pub_id}")

    def format_dutch_date(self, datestr):
        dateobj = dt.strptime(datestr, "%Y%m%dT%H%M%S%z")
        weekdays = ["maandag", "dinsdag", "woensdag", "donderdag", "vrijdag", "zaterdag", "zondag"]
        months = ["januari", "februari", "maart", "april", "mei", "juni", "juli", "augustus", "september", "oktober",
                  "november", "december"]
        return f"{weekdays[dateobj.weekday()]} {dateobj.day} {months[dateobj.month-1]} {dateobj.year}"

    def denormalize_id(self, pub_id):
        if len(str(pub_id)) < 13:
            return int(pub_id)
        sub = list(str(pub_id))[1:]
        while True:
            if sub[0] != "0":
                break
            sub.pop(0)
        return int("".join(sub))

    def build_xml(self, pub_id, title, subtitle, press_message,
                  post_date=dt.now(pytz.timezone("Europe/Brussels")).strftime("%Y%m%dT%H%M%S%z"),
                  first_created=dt.now(pytz.timezone("Europe/Brussels")).strftime("%Y%m%dT%H%M%S%z"),
                  this_revision_created=dt.now(pytz.timezone("Europe/Brussels")).strftime("%Y%m%dT%H%M%S%z"),
                  previous_revision="0", revision_update="N", revision_version="1", write_to_file=False):
        # https://lxml.de/tutorial.html
        pub_id = str(self.normalize_id(pub_id))
        root = etree.Element("NewsML")
        root.attrib["xmlns:xsi"] = "http://www.w3.org/2001/XLSSchema-instance"
        root.attrib["xsi:noNamespaceSchemaLocation"] = "NewsMLv1.1.xsd"
        root.attrib["Version"] = "1.1"

        newsenvelope = etree.Element("NewsEnvelope")  # Start of NewsEnvelope

        transmissionid = etree.Element("TransmissionID")
        transmissionid.attrib['Repeat'] = "0"
        transmissionid.text = pub_id
        newsenvelope.append(transmissionid)

        sentfrom = etree.Element("SentFrom")
        party_from = etree.Element("Party")
        party_from.attrib['FormalName'] = "Vo"
        property_vo_wsu = etree.Element("Property")
        property_vo_wsu.attrib['FormalName'] = "webserviceurl"
        property_vo_wsu.attrib['Value'] = "webserviceurl.vlaanderen.be"
        party_from.append(property_vo_wsu)
        property_vo_notify = etree.Element("Property")
        property_vo_notify.attrib['FormalName'] = "notify"
        property_vo_notify.attrib['Value'] = "nieuwsdienst@vlaanderden.be"
        party_from.append(property_vo_notify)
        sentfrom.append(party_from)
        newsenvelope.append(sentfrom)

        sentto = etree.Element("SentTo")
        party_to = etree.Element("Party")
        party_to.attrib['FormalName'] = "BELGA"
        property_belga_wsu = etree.Element("Property")
        property_belga_wsu.attrib['FormalName'] = "webserviceurl"
        property_belga_wsu.attrib['Value'] = "webserviceurl.belga.be"
        party_to.append(property_belga_wsu)
        sentto.append(party_to)
        newsenvelope.append(sentto)

        etree.SubElement(newsenvelope, "DateAndTime").text = post_date

        root.append(newsenvelope)  # End of NewsEnvelope

        newsitem = etree.Element("NewsItem")

        identification = etree.Element("Identification")
        newsidentifier = etree.Element("NewsIdentifier")
        etree.SubElement(newsidentifier, "ProviderId").text = "nieuws.vlaanderen.be"
        etree.SubElement(newsidentifier, "DateId").text = post_date[:8]
        etree.SubElement(newsidentifier, "NewsItemId").text = pub_id
        revisionid = etree.Element("RevisionId")
        revisionid.attrib['PreviousRevision'] = previous_revision
        revisionid.attrib['Update'] = revision_update
        revisionid.text = revision_version
        newsidentifier.append(revisionid)
        etree.SubElement(newsidentifier, "PublicIdentifier").text = f"urn:newsml:nieuws.vlaanderen.be:{post_date[:8]}:{pub_id}:11N"  # TODO check!, example was "urn:newsml:nieuws.vlaanderen.be:20190118:2000000215888:11N"
        identification.append(newsidentifier)
        newsitem.append(identification)

        newsmanagement = etree.Element("NewsManagement")
        newsitemtype = etree.Element("NewsItemType")
        newsitemtype.attrib['FormalName'] = "news"
        newsitemtype.attrib['Scheme'] = "IptcNewsItemType"
        newsmanagement.append(newsitemtype)
        etree.SubElement(newsmanagement, "FirstCreated").text = first_created
        etree.SubElement(newsmanagement, "ThisRevisionCreated").text = this_revision_created
        newsmngtstatus = etree.Element("Status")
        newsmngtstatus.attrib['FormalName'] = "Usable"
        newsmngtstatus.attrib['Scheme'] = "IptcStatus"
        newsmanagement.append(newsmngtstatus)
        newsitem.append(newsmanagement)

        newscomponent = etree.Element("NewsComponent")

        newslines = etree.Element("NewsLines")
        etree.SubElement(newslines, "HeadLine").text = title
        etree.SubElement(newslines, "SubHeadLine").text = subtitle
        etree.SubElement(newslines, "DateLine").text = self.format_dutch_date(post_date)
        newscomponent.append(newslines)

        descriptivemeta = etree.Element("DescriptiveMetadata")
        etree.SubElement(descriptivemeta, "Language").attrib['FormalName'] = "nl"  # TODO Always NL?
        genre = etree.Element("Genre")
        genre.attrib['FormalName'] = "nieuws.vlaanderen.be"
        genre.attrib['Scheme'] = "IptcGenre"
        descriptivemeta.append(genre)
        newscomponent.append(descriptivemeta)

        subnewscomponent = etree.Element("NewsComponent")
        etree.SubElement(subnewscomponent, "Comment").text = pub_id
        role = etree.Element("Role")
        role.attrib['FormalName'] = "Main"
        role.attrib['Scheme'] = "IptcRole"
        subnewscomponent.append(role)
        contentitem = etree.Element("ContentItem")
        etree.SubElement(contentitem, "Comment").text = pub_id
        etree.SubElement(contentitem, "DataContent").text = f"<![CDATA[{press_message}]]>"
        subnewscomponent.append(contentitem)
        newscomponent.append(subnewscomponent)
        newsitem.append(newscomponent)
        root.append(newsitem)

        if write_to_file:
            outfile = open(f"{pub_id}.xml", 'w')
            outfile.write(etree.tostring(root).decode('UTF-8'))
            outfile.close()

        return b'<?xml version="1.0" encoding="utf-8"?>' + etree.tostring(root)
