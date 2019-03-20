    Brute-force line-by-line non-recursive parsing
---
    The MIT License (MIT)
    Copyright (c) 2019 JFrog LTD

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software
    and associated documentation files (the "Software"), to deal in the Software without
    restriction, including without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or
    substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
    PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
    ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
__author__ = "Conan.io <info@conan.io>"
__version__ = "1.17.4"
__license__ = "MIT"
__url__ = "https://github.com/conan-io/python-patch"
import tempfile
import codecs
import stat
  return b.decode('utf-8')
# module name (e.g. 'patch' for patch_ng.py module)
logger = logging.getLogger("patch_ng")
error = logger.error

def safe_unlink(filepath):
  os.chmod(filepath, stat.S_IWUSR | stat.S_IWGRP | stat.S_IWOTH)
  os.unlink(filepath)


def decode_text(text):
  encodings = {codecs.BOM_UTF8: "utf_8_sig",
               codecs.BOM_UTF16_BE: "utf_16_be",
               codecs.BOM_UTF16_LE: "utf_16_le",
               codecs.BOM_UTF32_BE: "utf_32_be",
               codecs.BOM_UTF32_LE: "utf_32_le",
               b'\x2b\x2f\x76\x38': "utf_7",
               b'\x2b\x2f\x76\x39': "utf_7",
               b'\x2b\x2f\x76\x2b': "utf_7",
               b'\x2b\x2f\x76\x2f': "utf_7",
               b'\x2b\x2f\x76\x38\x2d': "utf_7"}
  for bom in sorted(encodings, key=len, reverse=True):
    if text.startswith(bom):
      try:
        return text[len(bom):].decode(encodings[bom])
      except UnicodeDecodeError:
        continue
  decoders = ["utf-8", "Windows-1252"]
  for decoder in decoders:
    try:
      return text.decode(decoder)
    except UnicodeDecodeError:
      continue
  logger.warning("can't decode %s" % str(text))
  return text.decode("utf-8", "ignore")  # Ignore not compatible characters


def to_file_bytes(content):
  if PY3K:
    if not isinstance(content, bytes):
      content = bytes(content, "utf-8")
  elif isinstance(content, unicode):
    content = content.encode("utf-8")
  return content


def load(path, binary=False):
  """ Loads a file content """
  with open(path, 'rb') as handle:
    tmp = handle.read()
    return tmp if binary else decode_text(tmp)


def save(path, content, only_if_modified=False):
  """
  Saves a file with given content
  Params:
      path: path to write file to
      content: contents to save in the file
      only_if_modified: file won't be modified if the content hasn't changed
  """
  try:
    os.makedirs(os.path.dirname(path))
  except Exception:
    pass

  new_content = to_file_bytes(content)

  if only_if_modified and os.path.exists(path):
    old_content = load(path, binary=True)
    if old_content == new_content:
      return

  with open(path, "wb") as handle:
    handle.write(new_content)


    self.source = None

              # TODO check for \No new line at the end..


            # Files dated at Unix epoch don't exist, e.g.:
            # '1970-01-01 01:00:00.000000000 +0100'
            # They include timezone offsets.
            # .. which can be parsed (if we remove the nanoseconds)
            # .. by strptime() with:
            # '%Y-%m-%d %H:%M:%S %z'
            # .. but unfortunately this relies on the OSes libc
            # strptime function and %z support is patchy, so we drop
            # everything from the . onwards and group the year and time
            # separately.
          re_filename_date_time = b"^--- ([^\t]+)(?:\s([0-9-]+)\s([0-9:]+)|.*)"
          match = re.match(re_filename_date_time, line)
            date = match.group(2)
            time = match.group(3)
            if (date == b'1970-01-01' or date == b'1969-12-31') and time.split(b':',1)[1] == b'00:00':
              srcname = b'/dev/null'
            # XXX seems to be a dead branch
            re_filename_date_time = b"^\+\+\+ ([^\t]+)(?:\s([0-9-]+)\s([0-9:]+)|.*)"
            match = re.match(re_filename_date_time, line)
              tgtname = match.group(1).strip()
              date = match.group(2)
              time = match.group(3)
              if (date == b'1970-01-01' or date == b'1969-12-31') and time.split(b':',1)[1] == b'00:00':
                  tgtname = b'/dev/null'
              p.target = tgtname
              tgtname = None
          pass

            and re.match(b'(?:index \\w{7}..\\w{7} \\d{6}|new file mode \\d*)', p.header[idx+1])):
    #
    #    ...

        debug("    patch type = %s" % p.type)
        debug("    source = %s" % p.source)
        debug("    target = %s" % p.target)
        if p.source != b'/dev/null':
        if p.target != b'/dev/null':
      if (xisabs(p.source) and p.source != b'/dev/null') or \
         (xisabs(p.target) and p.target != b'/dev/null'):
        if xisabs(p.source) and p.source != b'/dev/null':
        if xisabs(p.target) and p.target != b'/dev/null':


  def findfiles(self, old, new):
    """ return tuple of source file, target file """
    if old == b'/dev/null':
      handle, abspath = tempfile.mkstemp(suffix='pypatch')
      abspath = abspath.encode()
      # The source file must contain a line for the hunk matching to succeed.
      os.write(handle, b' ')
      os.close(handle)
      if not exists(new):
        handle = open(new, 'wb')
        handle.close()
      return abspath, new
    elif exists(old):
      return old, old
      return new, new
    elif new == b'/dev/null':
      return None, None
          return old, old
          return new, new
      return None, None

  def _strip_prefix(self, filename):
    if filename.startswith(b'a/') or filename.startswith(b'b/'):
        return filename[2:]
    return filename

  def decode_clean(self, path, prefix):
    path = path.decode("utf-8").replace("\\", "/")
    if path.startswith(prefix):
      path = path[2:]
    return path

  def strip_path(self, path, base_path, strip=0):
    tokens = path.split("/")
    if len(tokens) > 1:
      tokens = tokens[strip:]
    path = "/".join(tokens)
    if base_path:
      path = os.path.join(base_path, path)
    return path
    # account for new and deleted files, upstream dep won't fix them


  def apply(self, strip=0, root=None, fuzz=False):
        :param strip: Strip patch path
        :param root: Folder to apply the patch
        :param fuzz: Accept fuzzy patches
    items = []
    for item in self.items:
      source = self.decode_clean(item.source, "a/")
      target = self.decode_clean(item.target, "b/")
      if "dev/null" in source:
        target = self.strip_path(target, root, strip)
        hunks = [s.decode("utf-8") for s in item.hunks[0].text]
        new_file = "".join(hunk[1:] for hunk in hunks)
        save(target, new_file)
      elif "dev/null" in target:
        source = self.strip_path(source, root, strip)
        safe_unlink(source)
      else:
        items.append(item)
    self.items = items

        old = p.source if p.source == b'/dev/null' else pathstrip(p.source, strip)
        new = p.target if p.target == b'/dev/null' else pathstrip(p.target, strip)
      filenameo, filenamen = self.findfiles(old, new)

      if not filenameo or not filenamen:
        error("source/target file does not exist:\n  --- %s\n  +++ %s" % (old, new))
        errors += 1
        continue
      if not isfile(filenameo):
        error("not a file - %s" % filenameo)
      debug("processing %d/%d:\t %s" % (i+1, total, filenamen))
      f2fp = open(filenameo, 'rb')
        if lineno+1 < hunk.startsrc+len(hunkfind):
            hunklineno += 1
            warning("file %d/%d:\t %s" % (i+1, total, filenamen))
            warning(" hunk no.%d doesn't match source file at line %d" % (hunkno+1, lineno+1))
            warning("  expected: %s" % hunkfind[hunklineno])
            warning("  actual  : %s" % line.rstrip(b"\r\n"))
            if fuzz:
              hunklineno += 1
              # not counting this as error, because file may already be patched.
              # check if file is already patched is done after the number of
              # invalid hunks if found
              # TODO: check hunks against source/target file in one pass
              #   API - check(stream, srchunks, tgthunks)
              #           return tuple (srcerrs, tgterrs)

              # continue to check other hunks for completeness
              hunkno += 1
              if hunkno < len(p.hunks):
                hunk = p.hunks[hunkno]
                continue
              else:
                break
        if len(hunkfind) == 0 or lineno+1 == hunk.startsrc+len(hunkfind)-1:
          debug(" hunk no.%d for file %s  -- is ready to be patched" % (hunkno+1, filenamen))
        if hunkno < len(p.hunks):
          error("premature end of source file %s at hunk %d" % (filenameo, hunkno+1))
        if self._match_file_hunks(filenameo, p.hunks):
          warning("already patched  %s" % filenameo)
          if fuzz:
            warning("source file is different - %s" % filenameo)
          else:
            error("source file is different - %s" % filenameo)
            errors += 1
        backupname = filenamen+b".orig"
          errors += 1
          shutil.move(filenamen, backupname)
          if self.write_hunks(backupname if filenameo == filenamen else filenameo, filenamen, p.hunks):
            info("successfully patched %d/%d:\t %s" % (i+1, total, filenamen))
            safe_unlink(backupname)
            if new == b'/dev/null':
              # check that filename is of size 0 and delete it.
              if os.path.getsize(filenamen) > 0:
                warning("expected patched file to be empty as it's marked as deletion:\t %s" % filenamen)
              safe_unlink(filenamen)
            warning("error patching file %s" % filenamen)
            shutil.copy(filenamen, filenamen+".invalid")
            warning("invalid version is saved to %s" % filenamen+".invalid")
            shutil.move(backupname, filenamen)

            yield get_line()
            continue

  opt.add_option("-f", "--fuzz", action="store_true", dest="fuzz", help="Accept fuuzzy patches")
  if not patch:
    error("Could not parse patch")
    sys.exit(-1)

    patch.apply(options.strip, root=options.directory, fuzz=options.fuzz) or sys.exit(-1)
  # todo: document and test line ends handling logic - patch_ng.py detects proper line-endings