/*
Copyright NetFoundry Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

using System;
using System.IO;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace OpenZiti.NET.Samples {

    [Sample("weather")]
    public class Weather : SampleBase {
        public override async Task RunAsync(string[] args) {
            var identityFile = "";
            var c = new ZitiContext(identityFile);
            var zitiSocketHandler = c.NewZitiSocketHandler("weather-svc");
            var client = new HttpClient(new OpenZiti.Debugging.LoggingHandler(zitiSocketHandler));
            client.DefaultRequestHeaders.Add("User-Agent", "curl/7.59.0");

            var result = client.GetStringAsync("https://wttr.in:443").Result;
        }
    }
}