"""
# module server 

- Julia version: 0.6.4
- Author: skhum
- Date: 2018-08-15

# Examples

```jldoctest
julia>
```
"""



module api  #module to handle any requests on julia

#global module imports
using Joseki, JSON

#functions or variables to export from the api module
export index

#index is a function that is called when one goes to
#'http://localhost:8080/', this is set an endpoint in ../index.jl

# req is of type HTTP.Request
#to set type req::HTTP.Request
function index(req)

#respond with an array as a result, check Joseki API on github
 json_responder(req, rand!(zeros(Int16,100),0:4000))

 end

end
