;; LEGACY: partial (possibly leave some time for the dust to settle)
(define-resource publication ()
  :class (s-prefix "besluitvorming:Publicatie") 
  :properties `(;; LEGACY: leave blank
                (:nuber-of-words :number ,(s-prefix "besluitvorming:aantalWoorden"))
                ;; LEGACY: leave blank
                (:digital :boolean ,(s-prefix "besluitvorming:digitaal"))
                ;; LEGACY: leave blank
                (:number :string ,(s-prefix "adms:identifier"))
                ;; LEGACY: leave blank
                (:shortTitle :string ,(s-prefix "eli:title_short"))
                (:final-publication-date :date ,(s-prefix "besluitvorming:uiterstePublicatiedatum"))
                ;; LEGACY: leave blank
                (:type :uri ,(s-prefix "dct:type")) ;; NOTE: Status-code as human-readable UR
                ;; LEGACY: leave blank
                (:NUMAC :number ,(s-prefix "besluitvorming:NUMAC"))) ;; optional, NOTE: proposition to treat Publicaties in Belgisch staatsblad as ordinary publicaties (filter on NUMAC for retrieving publicaties belgisch staatsblad) NOTE: made up property-URI besluitvorming:NUMAC
  :has-one `(;; LEGACY: leave blank or come up with a code list
             (publication-state :via ,(s-prefix "ext:publicatieStatus") ;; NOTE: More specific relationship then besluitvorming:status as mu-cl-resources workaround
                                :as "state")
             (document-version :via ,(s-prefix "dct:hasPart")
                               :as "document-versions")
                          
             ;; LEGACY: leave blank
             (person :via ,(s-prefix "besluitvorming:heeftAanvrager") ;; NOTE: used persoon instead of agent
                     :as "requested-by")
             ;; LEGACY: same as agenda-item
             (mandatee :via ,(s-prefix "besluitvorming:heeftBevoegde") ;; NOTE: used mandataris instead of agent
                       :as "mandatee"))
  :has-many `(;; LEGACY: leave blank
              (remark :via ,(s-prefix "rdfs:comment")
                      :as "remarks")
              (decision :via ,(s-prefix "besluitvorming:isGerealiseerdDoor")
                        :inverse t
                        :as "decisions"))
  :resource-base (s-url "http://data.vlaanderen.be/id/Publicatie/")
  :features '(include-uri)
  :on-path "publications")

;; LEGACY: leave blank for this scope but might be recovered some day
(define-resource publication-state ()
  :class (s-prefix "besluitvorming:PublicatieStatus") ;; NOTE: Should be subclass of besluitvorming:Status (mu-cl-resources reasoner workaround)
  :properties `((:date :datetime ,(s-prefix "besluitvorming:statusdatum")))
  :has-one `((publication :via ,(s-prefix "ext:publicatieStatus") ;; NOTE: More specific relationship then besluitvorming:status as mu-cl-resources workaround
                          :inverse t
                          :as "publication")
             (publication-state-code :via ,(s-prefix "ext:publicatieStatusCode")
                                    :as "state"))
  :has-many `((remark :via ,(s-prefix "rdfs:comment")
                      :as "remarks")) ;; NOTE: opmerkingEN would be more suitable?
  :resource-base (s-url "http://data.vlaanderen.be/id/PublicatieStatus/")
  :features '(include-uri)
  :on-path "publication-states")

;; LEGACY: code list might be provided based on PWC stuff
(define-resource publication-state-code ()
  :class (s-prefix "ext:PublicatieStatusCode") ;; NOTE: as well as skos:Concept
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :has-many `((publication-state :via ,(s-prefix "ext:publicatieStatusCode")
                          :inverse t
                          :as "publication-states")
              (publication-state-code :via ,(s-prefix "skos:broader") ;; NOTE: tree structure for type-hierarchy (cfr codelist)
                                      :inverse t
                                      :as "substates"))
  :has-one `((publication-state-code :via ,(s-prefix "skos:broader")
                                     :as "superstate"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/PublicatieStatusCode/")
  :features '(include-uri)
  :on-path "publication-state-codes")

;; LEGACY: leave blank
(define-resource remark ()
  :class (s-prefix "schema:Comment") ;; NOTE: instead of misusing 'rdfs:comment' property name as class name
  :properties `((:created :datetime ,(s-prefix "besluitvorming:aanmaakdatum")) ;; NOTE: Type should be :date instead?
                (:text :string ,(s-prefix "rdfs:comment")))
  :has-one `((person :via ,(s-prefix "dct:creator")
                     :as "author")
             (agendaitem :via ,(s-prefix "besluitvorming:opmerking")
                         :inverse t
                         :as "agendaitem"))
  :has-many `((remark    :via ,(s-prefix "ext:antwoorden")
                         :as "answers"))
  :resource-base (s-url "http://data.vlaanderen.be/id/Opmerking/")
  :features '(include-uri)
  :on-path "remarks")

;; LEGACY: partial
(define-resource newsletter-info ()
  :class (s-prefix "besluitvorming:NieuwsbriefInfo") 
  :properties `(;; LEGACY: create html field for original data and add stripped version in this field TODO karel create :rich_text field as string
                (:text :string ,(s-prefix "besluitvorming:inhoud"))
                ;; LEGACY: to be checked
                (:subtitle :string ,(s-prefix "dbpedia:subtitle"))
                (:publication-date :datetime ,(s-prefix "dct:issued"))
                ;; LEGACY: best effort
                (:publication-doc-date :datetime ,(s-prefix "ext:issuedDocDate"))
                ;; LEGACY: best effort difference between subtitle, if not available, same
                (:title :string ,(s-prefix "dct:title")))
  :has-one `((agendaitem :via ,(s-prefix "prov:generated") ;; NOTE: What is the domain of Besluit geeftAanleidingTot? guessed prov:generated
                         :as "agendaitem")
             (meeting    :via ,(s-prefix "ext:algemeneNieuwsbrief")
                         :inverse t
                         :as "meeting"))
  :has-many `(;; LEGACY: leave blank
              (remark :via ,(s-prefix "rdfs:comment")
                      :as "remarks") ;; NOTE: opmerkingEN would be more suitable?
              ;; LEGACY: yes but we won't use it
              (theme :via ,(s-prefix "dct:subject")
                     :as "themes"))
  :resource-base (s-url "http://data.vlaanderen.be/id/Publicatie/")
  :features '(include-uri)
  :on-path "newsletter-infos")

;; LEGACY: yay
(define-resource theme ()
  :class (s-prefix "ext:ThemaCode") ;; NOTE: as well as skos:Concept
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/ThemaCode/")
  :features '(include-uri)
  :on-path "themes")
