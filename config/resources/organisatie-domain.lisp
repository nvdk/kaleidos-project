;; LEGACY: leave entire file blank
(define-resource site ()
  :class (s-prefix "org:Site")
  :has-one `((contact-point :via ,(s-prefix "schema:contactPoint")
                            :as "contact-point"))
  :resource-base (s-url "http://data.lblod.info/id/vestiging/")
  :features '(include-uri)
  :on-path "sites"
)

(define-resource contact-point ()
  :class (s-prefix "schema:PostalAddress")
  :properties `((:country :string ,(s-prefix "schema:addressCountry"))
                (:municipality :string ,(s-prefix "schema:addressLocality"))
                (:address :string ,(s-prefix "schema:streetAddress"))
                (:postal-code :string ,(s-prefix "schema:postalCode"))
                (:email :string ,(s-prefix "schema:email"))
                (:telephone :string ,(s-prefix "schema:telephone"))
                (:fax :string ,(s-prefix "schema:faxNumber"))
                (:website :string ,(s-prefix "schema:url")))
  :resource-base (s-url "http://data.lblod.info/id/contactpunt/")
  :features '(include-uri)
  :on-path "contact-points"
)

(define-resource post ()
  :class (s-prefix "org:Post")
  :has-one `((role :via ,(s-prefix "org:role")
                  :as "role")
             (organization :via ,(s-prefix "org:hasPost")
                           :inverse t
                           :as "organization"))
  :has-many `((person :via ,(s-prefix "org:heldBy")
                       :as "wordt-ingevuld-door"))
  :resource-base (s-url "http://data.lblod.info/id/positie/")
  :features '(include-uri)
  :on-path "posts"
)

(define-resource role ()
  :class (s-prefix "org:Role")
  :properties `((:label :string ,(s-prefix "skos:prefLabel")))
  :resource-base (s-url "http://data.lblod.info/id/concept/bestuurseenheidRollen/")
  :features '(include-uri)
  :on-path "roles"
)

(define-resource organization ()
  :class (s-prefix "org:Organization")
  :properties `((:name :string ,(s-prefix "skos:prefLabel")))
  :has-one `((site :via ,(s-prefix "org:hasPrimarySite")
                   :as "site")
             )
  :has-many `((contact-point :via ,(s-prefix "schema:contactPoint")
                             :as "contact-points")
              (post :via ,(s-prefix "org:hasPost")
                    :as "posts"))
  :resource-base (s-url "http://data.lblod.info/id/organisaties/")
  :features '(include-uri)
  :on-path "organizations"
)

