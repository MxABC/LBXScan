/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXBoolArray.h"
#import "ZXCodaBarReader.h"
#import "ZXCodaBarWriter.h"

const unichar ZX_CODA_START_END_CHARS[] = {'A', 'B', 'C', 'D'};
const unichar ZX_CODA_ALT_START_END_CHARS[] = {'T', 'N', '*', 'E'};
const unichar ZX_CHARS_WHICH_ARE_TEN_LENGTH_EACH_AFTER_DECODED[] = {'/', ':', '+', '.'};

@implementation ZXCodaBarWriter

- (ZXBoolArray *)encode:(NSString *)contents {
  if ([contents length] < 2) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"Codabar should start/end with start/stop symbols"
                                 userInfo:nil];
  }

  // Verify input and calculate decoded length.
  unichar firstChar = [[contents uppercaseString] characterAtIndex:0];
  unichar lastChar = [[contents uppercaseString] characterAtIndex:contents.length - 1];
  BOOL startsEndsNormal =
    [ZXCodaBarReader arrayContains:ZX_CODA_START_END_CHARS length:sizeof(ZX_CODA_START_END_CHARS) / sizeof(unichar) key:firstChar] &&
    [ZXCodaBarReader arrayContains:ZX_CODA_START_END_CHARS length:sizeof(ZX_CODA_START_END_CHARS) / sizeof(unichar) key:lastChar];
  BOOL startsEndsAlt =
    [ZXCodaBarReader arrayContains:ZX_CODA_ALT_START_END_CHARS length:sizeof(ZX_CODA_ALT_START_END_CHARS) / sizeof(unichar) key:firstChar] &&
    [ZXCodaBarReader arrayContains:ZX_CODA_ALT_START_END_CHARS length:sizeof(ZX_CODA_ALT_START_END_CHARS) / sizeof(unichar) key:lastChar];
  if (!(startsEndsNormal || startsEndsAlt)) {
    NSString *reason = [NSString stringWithFormat:@"Codabar should start/end with %@, or start/end with %@",
                        [NSString stringWithCharacters:ZX_CODA_START_END_CHARS length:sizeof(ZX_CODA_START_END_CHARS) / sizeof(unichar)],
                        [NSString stringWithCharacters:ZX_CODA_ALT_START_END_CHARS length:sizeof(ZX_CODA_ALT_START_END_CHARS) / sizeof(unichar)]];
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:reason
                                 userInfo:nil];
  }

  // The start character and the end character are decoded to 10 length each.
  int resultLength = 20;
  for (int i = 1; i < contents.length - 1; i++) {
    if (([contents characterAtIndex:i] >= '0' && [contents characterAtIndex:i] <= '9') ||
        [contents characterAtIndex:i] == '-' || [contents characterAtIndex:i] == '$') {
      resultLength += 9;
    } else if ([ZXCodaBarReader arrayContains:ZX_CHARS_WHICH_ARE_TEN_LENGTH_EACH_AFTER_DECODED length:4 key:[contents characterAtIndex:i]]) {
      resultLength += 10;
    } else {
      @throw [NSException exceptionWithName:NSInvalidArgumentException
                                     reason:[NSString stringWithFormat:@"Cannot encode : '%C'", [contents characterAtIndex:i]]
                                   userInfo:nil];
    }
  }
  // A blank is placed between each character.
  resultLength += contents.length - 1;

  ZXBoolArray *result = [[ZXBoolArray alloc] initWithLength:resultLength];
  int position = 0;
  for (int index = 0; index < contents.length; index++) {
    unichar c = [[contents uppercaseString] characterAtIndex:index];
    if (index == 0 || index == contents.length - 1) {
      // The start/end chars are not in the CodaBarReader.ALPHABET.
      switch (c) {
        case 'T':
          c = 'A';
          break;
        case 'N':
          c = 'B';
          break;
        case '*':
          c = 'C';
          break;
        case 'E':
          c = 'D';
          break;
      }
    }
    int code = 0;
    for (int i = 0; i < ZX_CODA_ALPHABET_LEN; i++) {
      // Found any, because I checked above.
      if (c == ZX_CODA_ALPHABET[i]) {
        code = ZX_CODA_CHARACTER_ENCODINGS[i];
        break;
      }
    }
    BOOL color = YES;
    int counter = 0;
    int bit = 0;
    while (bit < 7) { // A character consists of 7 digit.
      result.array[position] = color;
      position++;
      if (((code >> (6 - bit)) & 1) == 0 || counter == 1) {
        color = !color; // Flip the color.
        bit++;
        counter = 0;
      } else {
        counter++;
      }
    }
    if (index < contents.length - 1) {
      result.array[position] = NO;
      position++;
    }
  }
  return result;
}

@end
