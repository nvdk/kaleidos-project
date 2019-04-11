;; TODO karel check
(define-resource document-state ()
  :class (s-prefix "ext:DocumentStatus")
  :properties `((:label :string ,(s-prefix "skos:prefLabel")))
  :resource-base (s-url "http://data.lblod.info/document-statuses/")
  :features `(no-pagination-defaults include-uri)
  :on-path "document-states")

;; LEGACY: one to one mapping with documentversion (and therefore documents) TODO karel: what's with the difference between physical and logical files and how is it different from files FOR NOW KEEP IT
(define-resource file ()
  :class (s-prefix "nfo:FileDataObject")
  :properties `((:filename :string ,(s-prefix "nfo:fileName"))
                (:format :string ,(s-prefix "dct:format"))
                (:size :number ,(s-prefix "nfo:fileSize"))
                (:extension :string ,(s-prefix "dbpedia:fileExtension"))
                (:created :datetime ,(s-prefix "nfo:fileCreated")))
  :has-one `((file :via ,(s-prefix "nie:dataSource")
                   :inverse t
                   :as "download"))
  :resource-base (s-url "http://data.lblod.info/files/")
  :features `(no-pagination-defaults include-uri)
  :on-path "files")

;; TODO karel remove
(define-resource file-address ()
  :class (s-prefix "ext:FileAddress")
  :properties `((:address :url ,(s-prefix "ext:fileAddress")))
  :resource-base (s-url "http://data.lblod.info/file-addresses/")
  :features `(no-pagination-defaults include-uri)
  :on-path "file-addresses")
