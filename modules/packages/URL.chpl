/*
 * Copyright 2020-2024 Hewlett Packard Enterprise Development LP
 * Copyright 2004-2019 Cray Inc.
 * Other additional copyright holders may be indicated within.
 *
 * The entirety of this work is licensed under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 *
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*

Download data from a URL or upload data to a URL.

For example, the following program downloads a web-page from http://example.com and outputs each line to stdout:

.. code-block:: chapel

  use URL;
  var urlreader = openUrlReader("http://example.com");
  var str:bytes;
  // Output each line read from the URL to stdout
  while(urlreader.readLine(str)) {
    write(str);
  }

.. note::

  This module is currently implemented using :mod:`Curl`. As such, please see
  the :mod:`Curl` documentation to see which protocols are available.

 */

module URL {
  public use IO;

  pragma "last resort"
  @deprecated("openUrlReader with a style and/or kind argument is deprecated")
  proc openUrlReader(url:string,
                     param kind=iokind.dynamic, param locking=true,
                     start:int(64) = 0, end:int(64) = max(int(64)),
                     style:iostyle)
                    : fileReader(kind, locking) throws {
    var region = if end == max(int(64)) then start..end else start..(end-1);
    return openUrlReaderHelper(url, kind, locking, region, style: iostyleInternal);
  }

  pragma "last resort"
  @deprecated("openUrlReader with a start and/or end argument is deprecated. Please use the new region argument instead.")
  proc openUrlReader(url:string, param locking=true,
                     start:int(64) = 0, end:int(64) = max(int(64)))
                    : fileReader(locking) throws {
    var region = if end == max(int(64)) then start..end else start..(end-1);
    return openUrlReaderHelper(url, _iokind.dynamic, locking, region);
  }

  /*

  Open a fileReader from a particular URL.

  :arg url: which url to open (for example, "http://example.com").
  :arg locking: compile-time argument to determine whether or not the
                channel should use locking; sets the
                corresponding parameter of the :record:`~IO.fileReader` type.
                Defaults to true, but when safe, setting it to false
                can improve performance.
  :arg region: zero-based byte offset indicating where in the file the
               fileReader should read. Defaults to ``0..`` - meaning from the
               start of the file to no end point.
  :returns: an open fileReader to the requested resource.

  :throws SystemError: Thrown if a fileReader could not be returned.
   */
  proc openUrlReader(url:string, param locking=true,
                     region: range(?) = 0..)
                    : fileReader(locking) throws {
    return openUrlReaderHelper(url, _iokind.dynamic, locking, region);
  }

  private
  proc openUrlReaderHelper(url:string,
                           param kind=_iokind.dynamic, param locking=true,
                           region: range(?) = 0..,
                           style:iostyleInternal = defaultIOStyleInternal())
    : fileReader(kind, locking) throws {

    use Curl;
    use CurlQioIntegration;
    var f = openCurlFile(url, ioMode.r, style);
    // TODO: change this back to f.reader when the kind argument is removed
    return f.readerHelper(kind=kind, locking=locking, region=region);
  }

  pragma "last resort"
  @deprecated("openUrlWriter with a style and/or kind argument is deprecated")
  proc openUrlWriter(url:string,
                 param kind=iokind.dynamic, param locking=true,
                 start:int(64) = 0, end:int(64) = max(int(64)),
                 style:iostyle)
                : fileWriter(kind, locking) throws {
    var region = if end == max(int(64)) then start..end else start..(end-1);
    return openUrlWriterHelper(url, kind, locking, region, style: iostyleInternal);
  }

  pragma "last resort"
  @deprecated("openUrlWriter with a start and/or end argument is deprecated. Please use the new region argument instead.")
  proc openUrlWriter(url:string, param locking=true,
                 start:int(64) = 0, end:int(64) = max(int(64)))
                : fileWriter(locking) throws {
    var region = if end == max(int(64)) then start..end else start..(end-1);
    return openUrlWriterHelper(url, _iokind.dynamic, locking, region);
  }

  /*

  Open a fileWriter to a particular URL.

  :arg path: which file to open (for example, "ftp://127.0.0.1/upload/test.txt")
  :arg locking: compile-time argument to determine whether or not the
                fileWriter should use locking; sets the
                corresponding parameter of the :record:`~IO.fileWriter` type.
                Defaults to true, but when safe, setting it to false
                can improve performance.
  :arg region: zero-based byte offset indicating where in the file the
               fileWriter should write. Defaults to ``0..`` - meaning from the
               start of the file to no end point.
  :returns: an open fileWriter to the requested resource.

  :throws SystemError: Thrown if a fileWriter could not be returned.
  */
  proc openUrlWriter(url:string, param locking=true,
                 region: range(?) = 0..)
                : fileWriter(locking) throws {
    return openUrlWriterHelper(url, _iokind.dynamic, locking, region);
  }

  private proc openUrlWriterHelper(url:string,
                                   param kind=_iokind.dynamic,
                                   param locking=true,
                                   region: range(?) = 0..,
                                   style:iostyleInternal = defaultIOStyleInternal())
    : fileWriter(kind, locking) throws {

    use Curl;
    use CurlQioIntegration;
    var f = openCurlFile(url, ioMode.cw, style);
    // TODO: change this back to f.writer when the kind argument has been
    // removed
    return f.writerHelper(kind=kind, locking=locking, region=region);
  }

}
