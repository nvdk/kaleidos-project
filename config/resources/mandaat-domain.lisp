;; LEGACY: leave blank
(define-resource birth ()
  :class (s-prefix "persoon:Geboorte")
  :properties `((:date :date ,(s-prefix "persoon:datum")))
  :resource-base (s-url "http://data.lblod.info/id/geboortes/")
  :features '(include-uri)
  :on-path "geboortes")

;; LEGACY: create one for minister, adding minister president is not possible, will be regular minister
(define-resource mandate ()
  :class (s-prefix "mandaat:Mandaat")
  :properties `((:number-of-mandatees :number ,(s-prefix "mandaat:aantalHouders")))
  :has-one `(
             (government-function :via ,(s-prefix "org:role")
                                  :as "function")
             ;; LEGACY: just a single one
             (government-body :via ,(s-prefix "org:hasPost")
                                   :inverse t
                                   :as "bevat-in"))
  :resource-base (s-url "http://data.lblod.info/id/mandaten/")
  :features '(include-uri)
  :on-path "mandates")

;; LEGACY: leave blank, TODO karel should fix: minister and minister president are functions. TODO michael: create code lists
(define-resource government-function ()
  :class (s-prefix "ext:BestuursfunctieCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/BestuursfunctieCode/")
  :features '(include-uri)
  :on-path "government-functions")

;; LEGACY: generate based on data, supported by wikipedia
(define-resource mandatee ()
  :class (s-prefix "mandaat:Mandataris")
  :properties `(;; LEGACY: leave blank
                (:priority        :string ,(s-prefix "mandaat:rangorde"))
                ;; LEGACY: from wikipedia
                (:start           :datetime ,(s-prefix "mandaat:start"))
                ;; LEGACY: from wikipedia
                (:end             :datetime ,(s-prefix "mandaat:einde"))
                ;; LEGACY: from wikipedia
                (:date-sworn-in   :datetime ,(s-prefix "ext:datumEedaflegging"))
                ;; LEGACY: leave blank
                (:date-decree     :datetime ,(s-prefix "ext:datumMinistrieelBesluit"))
                (:title           :string ,(s-prefix "dct:title")))
  :has-many `(
    ;; (mandatee                  :via ,(s-prefix "mandaat:isTijdelijkVervangenDoor")
              ;;                            :as "temporary-replacements")
              ;; LEGACY: leave blank
              (government-domain  :via ,(s-prefix "mandaat:beleidsdomein")
                                  :as "government-domains")
              ;; LEGACY: leave blank
              (decision           :via ,(s-prefix "besluitvorming:neemtBesluit") ;; NOTE: What is the URI of property 'neemt' (Agent neemt besluit)? Guessed besluitvorming:neemtBesluit 
                                  :inverse t
                                  :as "decisions")
              (case               :via ,(s-prefix "besluitvorming:heeftBevoegde") ;; NOTE: used mandataris instead of agent
                                  :inverse t
                                  :as "cases")
              ;; LEGACY: leave blank
              (meeting-record     :via ,(s-prefix "ext:aanwezigen")
                                  :as "meetings-attended")
              ;; LEGACY: leave blank
              (approval           :via ,(s-prefix "ext:goedkeuringen")
                                  :as "approvals"))
  :has-one `((mandate             :via ,(s-prefix "org:holds")
                                  :as "holds")
             (person              :via ,(s-prefix "mandaat:isBestuurlijkeAliasVan")
                                  :as "person")
             ;; LEGACY: leave blank (we don't have it either)
             (mandatee-state      :via ,(s-prefix "mandaat:status")
                                  :as "state"))
  :resource-base (s-url "http://data.lblod.info/id/mandatarissen/")
  :features '(include-uri)
  :on-path "mandatees")

;; LEGACY: leave blank
(define-resource mandatee-state ()
  :class (s-prefix "ext:MandatarisStatusCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/MandatarisStatusCode/")
  :features '(include-uri)
  :on-path "madatee-states")

;; LEGACY: leave blank
(define-resource government-domain ()
  :class (s-prefix "ext:BeleidsdomeinCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :has-many `((mandatee :via ,(s-prefix "mandaat:beleidsdomein")
                        :inverse t
                        :as "mandatees"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/BeleidsdomeinCode/")
  :features '(include-uri)
  :on-path "government-domains")

;; LEGACY: leave blank
(define-resource jurisdiction ()
  :class (s-prefix "ext:BevoegdheidCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :has-many `((mandatee :via ,(s-prefix "ext:bevoegdheid")
                        :inverse t
                        :as "mandatees"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/BevoegdheidCode/")
  :features '(include-uri)
  :on-path "responsibilities")

;; LEGACY: best effort (last name may collide)
(define-resource person ()
  :class (s-prefix "person:Person")
  :properties `((:last-name         :string ,(s-prefix "foaf:familyName"))
                ;; LEGACY: leave blank
                (:alternative-name  :string ,(s-prefix "foaf:name"))
                (:first-name        :string ,(s-prefix "foaf:firstName")))
  :has-many `((mandatee             :via    ,(s-prefix "mandaat:isBestuurlijkeAliasVan")
                                    :inverse t
                                    :as "mandatees"))
  ;; LEGACY: leave blank
  :has-one `((identification        :via    ,(s-prefix "ext:identifier")
                                    :as "identifier"))
             ;; (gender :via ,(s-prefix "persoon:geslacht")
             ;;         :as "gender")
             ;; (birth :via ,(s-prefix "persoon:heeftGeboorte")
             ;;      :as "birth")
  :resource-base (s-url "http://data.lblod.info/id/personen/")
  :features '(include-uri)
  :on-path "people")

;; LEGACY: leave blank
(define-resource gender ()
  :class (s-prefix "ext:GeslachtCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/GeslachtCode/")
  :features '(include-uri)
  :on-path "genders")

;; LEGACY: leave blank
(define-resource identification ()
  :class (s-prefix "adms:Identifier")
  :properties `((:id-name :string ,(s-prefix "skos:notation"))) ;; TODO: should have a specific type
  :has-one `((person :via ,(s-prefix "ext:identifier")
                     :inverse t
                     :as "personId"))
  :resource-base (s-url "http://data.lblod.info/id/identificatoren/")
  :features '(include-uri)
  :on-path "identifications")
