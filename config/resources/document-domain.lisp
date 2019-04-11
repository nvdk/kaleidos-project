;; LEGACY: all documents of agendaitems go here
(define-resource document ()
  :class (s-prefix "foaf:Document")
  :properties `(;; LEGACY: leave blank
                (:archived        :boolean ,(s-prefix "besluitvorming:gearchiveerd"))
                (:title           :string ,(s-prefix "dct:title")) ;;string-set
                ;; LEGACY: best effort difference between title and description
                (:description     :string ,(s-prefix "ext:omschrijving")) ;;string-set
                ;; LEGACY: can be obtained through tooling over files
                (:created         :datetime ,(s-prefix "dct:created"))
                ;; LEGACY: leave blank
                (:number-vp       :string ,(s-prefix "besluitvorming:stuknummerVP")) ;; NOTE: What is the URI of property 'stuknummerVP'? Made up besluitvorming:stuknummerVP
                (:number-vr       :string ,(s-prefix "besluitvorming:stuknummerVR"))) ;; NOTE: What is the URI of property 'stuknummerVR'? Made up besluitvorming:stuknummerVR
  :has-many `( ;; LEGACY: leave blank
              (remark             :via ,(s-prefix "besluitvorming:opmerking")
                                  :as "remarks")
              ;; LEGACY: one to one mapping of document to version
              (document-version   :via ,(s-prefix "besluitvorming:heeftVersie")
                                  :as "document-versions"))
  :has-one `(;; TODO karel delete
             (decision            :via ,(s-prefix "ext:besluitHeeftDocument") ;; NOTE: Relation to document instad of document-subclass
                                  :inverse t
                                  :as "decision")
             ;; LEGACY: best effort, default fallback VARIA
             (document-type       :via ,(s-prefix "ext:documentType")
                                  :as "type")
             (confidentiality     :via ,(s-prefix "besluitvorming:vertrouwelijkheid")
                                  :as "confidentiality"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/Document/")
  :features '(include-uri)
  :on-path "documents")

;; LEGACY: one to one with document
(define-resource document-version ()
  :class (s-prefix "ext:DocumentVersie")
  :properties `(;; LEGACY: default is one
                (:version-number        :string   ,(s-prefix "ext:versieNummer"))
                (:created               :datetime ,(s-prefix "dct:created"))
                ;; LEGACY: will be different depending on the kind of document
                (:identification-number :string   ,(s-prefix "ext:idNumber"))
                ;; LEGACY: take from rewriten file name
                (:chosen-file-name      :string   ,(s-prefix "ext:gekozenDocumentNaam")))
  :has-one `((file                      :via      ,(s-prefix "ext:file")
                                        :as "file")
            (document                   :via      ,(s-prefix "besluitvorming:heeftVersie")
                                        :inverse t
                                        :as "document")
            (subcase                    :via ,(s-prefix "ext:bevatDocumentversie")
                                        :inverse t
                                        :as "subcase")
            (announcement               :via ,(s-prefix "ext:mededelingBevatDocumentversie")
                                        :inverse t
                                        :as "announcement"))
  :has-many `((document-vo-identifier   :via ,(s-prefix "ext:identifiesVersion")
                                        :as "identifiers"
                                        :inverse t))
  :resource-base (s-url "http://localhost/vo/document-versions/")
  :features `(include-uri)
  :on-path "document-versions")

;; LEGACY: ignore and come back to karel after 18th of april
(define-resource document-vo-identifier ()
  :class (s-prefix "ext:DocumentIdentifier")
  :properties `((:serial-number         :string   ,(s-prefix "ext:serieNummer"))
                (:version-number               :number   ,(s-prefix "ext:versieNummer")) ;; 1 for nothing, 2 for BIS, 3 for TER
                (:title                 :string   ,(s-prefix "dct:title"))) ;; title so people can give their own name to this version if necessary
  :has-one `((document-version          :via      ,(s-prefix "ext:identifiesVersion")
                                        :as "document-version")
            (meeting                    :via      ,(s-prefix "ext:meeting")
                                        :as "meeting")
            (subcase                    :via      ,(s-prefix "ext:procedurestap")
                                        :as "subcase"))
  :resource-base (s-url "http://localhost/vo/document-identifier/")
  :features `(include-uri)
  :on-path "document-vo-identifiers")

;; LEGACY: like Nota, Memo,...
(define-resource document-type ()
  :class (s-prefix "ext:DocumentTypeCode")
  :properties `((:label             :string ,(s-prefix "skos:prefLabel"))
                (:scope-note        :string ,(s-prefix "skos:scopeNote")))
  :has-many `((document             :via    ,(s-prefix "ext:documentType")
                                    :inverse t
                                    :as "documents")
              (document-type        :via    ,(s-prefix "skos:broader")
                                    :inverse t
                                    :as "subtypes"))
  :has-one `((document-type         :via    ,(s-prefix "skos:broader")
                                    :as "supertype"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/DocumentTypeCode/")
  :features '(include-uri)
  :on-path "document-types")

;; LEGACY: leave blank
(define-resource translation-request ()
  :class (s-prefix "besluitvorming:Vertalingsaanvraag")
  :properties `((:target-language :string ,(s-prefix "besluitvorming:doeltaal"))
                (:expected-delivery-date :date ,(s-prefix "besluitvorming:verwachteOpleverdatum")))
  :has-many `(
              (document-version :via ,(s-prefix "prov:generated")
                                :as "documentVersions")
              (translation-state :via ,(s-prefix "ext:vertalingsaanvraagStatus")
                                  :as "states")
              (remark :via ,(s-prefix "besluitvorming:opmerking")
                      :as "remarks")) ;; NOTE: opmerkingEN would be more suitable?
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/Vertalingsaanvraag/")
  :features '(include-uri)
  :on-path "translation-requests")

;; LEGACY: leave blank
(define-resource translation-state ()
  :class (s-prefix "besluitvorming:VertalingsaanvraagStatus") ;; NOTE: Should be subclass of besluitvorming:Status (mu-cl-resources reasoner workaround)
  :properties `((:date :datetime ,(s-prefix "besluitvorming:statusdatum")))
  :has-many `((remark :via ,(s-prefix "rdfs:comment")
                      :as "remarks"))
  :has-one `((translation-request :via ,(s-prefix "ext:vertalingsaanvraagStatus") ;; NOTE: More specific relationship then besluitvorming:status as mu-cl-resources workaround
                                 :inverse t
                                 :as "translationRequest")
             (translation-state-name :via ,(s-prefix "ext:vertalingsaanvraagStatusCode")
                                     :inverse t
                                     :as "value"))
  :resource-base (s-url "http://data.vlaanderen.be/id/VertalingsaanvraagStatus/")
  :features '(include-uri)
  :on-path "translation-states")

;; LEGACY: leave blank
(define-resource translation-state-name ()
  :class (s-prefix "besluitvorming:VertalingsaanvraagStatusCode") ;; NOTE: Should be subclass of besluitvorming:Status (mu-cl-resources reasoner workaround)
  :properties `((:label :string ,(s-prefix "skos:prefLabel")))
  :has-many `((translation-state :via ,(s-prefix "ext:vertalingsaanvraagStatusCode")
                                 :inverse t
                                 :as "translation-states"))
  :resource-base (s-url "http://data.vlaanderen.be/id/VertalingsaanvraagStatusCode/")
  :features '(include-uri)
  :on-path "translation-state-code")
