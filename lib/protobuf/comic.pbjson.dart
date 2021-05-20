///
//  Generated code. Do not modify.
//  source: comic.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use comicDetailResponseDescriptor instead')
const ComicDetailResponse$json = const {
  '1': 'ComicDetailResponse',
  '2': const [
    const {'1': 'Errno', '3': 1, '4': 1, '5': 5, '10': 'Errno'},
    const {'1': 'Errmsg', '3': 2, '4': 1, '5': 9, '10': 'Errmsg'},
    const {'1': 'Data', '3': 3, '4': 1, '5': 11, '6': '.dmzj.comic.ComicDetailInfoResponse', '10': 'Data'},
  ],
};

/// Descriptor for `ComicDetailResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List comicDetailResponseDescriptor = $convert.base64Decode('ChNDb21pY0RldGFpbFJlc3BvbnNlEhQKBUVycm5vGAEgASgFUgVFcnJubxIWCgZFcnJtc2cYAiABKAlSBkVycm1zZxI3CgREYXRhGAMgASgLMiMuZG16ai5jb21pYy5Db21pY0RldGFpbEluZm9SZXNwb25zZVIERGF0YQ==');
@$core.Deprecated('Use comicDetailInfoResponseDescriptor instead')
const ComicDetailInfoResponse$json = const {
  '1': 'ComicDetailInfoResponse',
  '2': const [
    const {'1': 'Id', '3': 1, '4': 1, '5': 5, '10': 'Id'},
    const {'1': 'Title', '3': 2, '4': 1, '5': 9, '10': 'Title'},
    const {'1': 'Direction', '3': 3, '4': 1, '5': 5, '10': 'Direction'},
    const {'1': 'Islong', '3': 4, '4': 1, '5': 5, '10': 'Islong'},
    const {'1': 'IsDmzj', '3': 5, '4': 1, '5': 5, '10': 'IsDmzj'},
    const {'1': 'Cover', '3': 6, '4': 1, '5': 9, '10': 'Cover'},
    const {'1': 'Description', '3': 7, '4': 1, '5': 9, '10': 'Description'},
    const {'1': 'LastUpdatetime', '3': 8, '4': 1, '5': 3, '10': 'LastUpdatetime'},
    const {'1': 'LastUpdateChapterName', '3': 9, '4': 1, '5': 9, '10': 'LastUpdateChapterName'},
    const {'1': 'Copyright', '3': 10, '4': 1, '5': 5, '10': 'Copyright'},
    const {'1': 'FirstLetter', '3': 11, '4': 1, '5': 9, '10': 'FirstLetter'},
    const {'1': 'ComicPy', '3': 12, '4': 1, '5': 9, '10': 'ComicPy'},
    const {'1': 'Hidden', '3': 13, '4': 1, '5': 5, '10': 'Hidden'},
    const {'1': 'HotNum', '3': 14, '4': 1, '5': 5, '10': 'HotNum'},
    const {'1': 'HitNum', '3': 15, '4': 1, '5': 5, '10': 'HitNum'},
    const {'1': 'Uid', '3': 16, '4': 1, '5': 5, '10': 'Uid'},
    const {'1': 'IsLock', '3': 17, '4': 1, '5': 5, '10': 'IsLock'},
    const {'1': 'LastUpdateChapterId', '3': 18, '4': 1, '5': 5, '10': 'LastUpdateChapterId'},
    const {'1': 'Types', '3': 19, '4': 3, '5': 11, '6': '.dmzj.comic.ComicDetailTypeItemResponse', '10': 'Types'},
    const {'1': 'Status', '3': 20, '4': 3, '5': 11, '6': '.dmzj.comic.ComicDetailTypeItemResponse', '10': 'Status'},
    const {'1': 'Authors', '3': 21, '4': 3, '5': 11, '6': '.dmzj.comic.ComicDetailTypeItemResponse', '10': 'Authors'},
    const {'1': 'SubscribeNum', '3': 22, '4': 1, '5': 5, '10': 'SubscribeNum'},
    const {'1': 'Chapters', '3': 23, '4': 3, '5': 11, '6': '.dmzj.comic.ComicDetailChapterResponse', '10': 'Chapters'},
    const {'1': 'IsNeedLogin', '3': 24, '4': 1, '5': 5, '10': 'IsNeedLogin'},
    const {'1': 'IsHideChapter', '3': 26, '4': 1, '5': 5, '10': 'IsHideChapter'},
  ],
};

/// Descriptor for `ComicDetailInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List comicDetailInfoResponseDescriptor = $convert.base64Decode('ChdDb21pY0RldGFpbEluZm9SZXNwb25zZRIOCgJJZBgBIAEoBVICSWQSFAoFVGl0bGUYAiABKAlSBVRpdGxlEhwKCURpcmVjdGlvbhgDIAEoBVIJRGlyZWN0aW9uEhYKBklzbG9uZxgEIAEoBVIGSXNsb25nEhYKBklzRG16ahgFIAEoBVIGSXNEbXpqEhQKBUNvdmVyGAYgASgJUgVDb3ZlchIgCgtEZXNjcmlwdGlvbhgHIAEoCVILRGVzY3JpcHRpb24SJgoOTGFzdFVwZGF0ZXRpbWUYCCABKANSDkxhc3RVcGRhdGV0aW1lEjQKFUxhc3RVcGRhdGVDaGFwdGVyTmFtZRgJIAEoCVIVTGFzdFVwZGF0ZUNoYXB0ZXJOYW1lEhwKCUNvcHlyaWdodBgKIAEoBVIJQ29weXJpZ2h0EiAKC0ZpcnN0TGV0dGVyGAsgASgJUgtGaXJzdExldHRlchIYCgdDb21pY1B5GAwgASgJUgdDb21pY1B5EhYKBkhpZGRlbhgNIAEoBVIGSGlkZGVuEhYKBkhvdE51bRgOIAEoBVIGSG90TnVtEhYKBkhpdE51bRgPIAEoBVIGSGl0TnVtEhAKA1VpZBgQIAEoBVIDVWlkEhYKBklzTG9jaxgRIAEoBVIGSXNMb2NrEjAKE0xhc3RVcGRhdGVDaGFwdGVySWQYEiABKAVSE0xhc3RVcGRhdGVDaGFwdGVySWQSPQoFVHlwZXMYEyADKAsyJy5kbXpqLmNvbWljLkNvbWljRGV0YWlsVHlwZUl0ZW1SZXNwb25zZVIFVHlwZXMSPwoGU3RhdHVzGBQgAygLMicuZG16ai5jb21pYy5Db21pY0RldGFpbFR5cGVJdGVtUmVzcG9uc2VSBlN0YXR1cxJBCgdBdXRob3JzGBUgAygLMicuZG16ai5jb21pYy5Db21pY0RldGFpbFR5cGVJdGVtUmVzcG9uc2VSB0F1dGhvcnMSIgoMU3Vic2NyaWJlTnVtGBYgASgFUgxTdWJzY3JpYmVOdW0SQgoIQ2hhcHRlcnMYFyADKAsyJi5kbXpqLmNvbWljLkNvbWljRGV0YWlsQ2hhcHRlclJlc3BvbnNlUghDaGFwdGVycxIgCgtJc05lZWRMb2dpbhgYIAEoBVILSXNOZWVkTG9naW4SJAoNSXNIaWRlQ2hhcHRlchgaIAEoBVINSXNIaWRlQ2hhcHRlcg==');
@$core.Deprecated('Use comicDetailTypeItemResponseDescriptor instead')
const ComicDetailTypeItemResponse$json = const {
  '1': 'ComicDetailTypeItemResponse',
  '2': const [
    const {'1': 'TagId', '3': 1, '4': 1, '5': 5, '10': 'TagId'},
    const {'1': 'TagName', '3': 2, '4': 1, '5': 9, '10': 'TagName'},
  ],
};

/// Descriptor for `ComicDetailTypeItemResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List comicDetailTypeItemResponseDescriptor = $convert.base64Decode('ChtDb21pY0RldGFpbFR5cGVJdGVtUmVzcG9uc2USFAoFVGFnSWQYASABKAVSBVRhZ0lkEhgKB1RhZ05hbWUYAiABKAlSB1RhZ05hbWU=');
@$core.Deprecated('Use comicDetailChapterResponseDescriptor instead')
const ComicDetailChapterResponse$json = const {
  '1': 'ComicDetailChapterResponse',
  '2': const [
    const {'1': 'Title', '3': 1, '4': 1, '5': 9, '10': 'Title'},
    const {'1': 'Data', '3': 2, '4': 3, '5': 11, '6': '.dmzj.comic.ComicDetailChapterInfoResponse', '10': 'Data'},
  ],
};

/// Descriptor for `ComicDetailChapterResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List comicDetailChapterResponseDescriptor = $convert.base64Decode('ChpDb21pY0RldGFpbENoYXB0ZXJSZXNwb25zZRIUCgVUaXRsZRgBIAEoCVIFVGl0bGUSPgoERGF0YRgCIAMoCzIqLmRtemouY29taWMuQ29taWNEZXRhaWxDaGFwdGVySW5mb1Jlc3BvbnNlUgREYXRh');
@$core.Deprecated('Use comicDetailChapterInfoResponseDescriptor instead')
const ComicDetailChapterInfoResponse$json = const {
  '1': 'ComicDetailChapterInfoResponse',
  '2': const [
    const {'1': 'ChapterId', '3': 1, '4': 1, '5': 5, '10': 'ChapterId'},
    const {'1': 'ChapterTitle', '3': 2, '4': 1, '5': 9, '10': 'ChapterTitle'},
    const {'1': 'Updatetime', '3': 3, '4': 1, '5': 3, '10': 'Updatetime'},
    const {'1': 'Filesize', '3': 4, '4': 1, '5': 5, '10': 'Filesize'},
    const {'1': 'ChapterOrder', '3': 5, '4': 1, '5': 5, '10': 'ChapterOrder'},
  ],
};

/// Descriptor for `ComicDetailChapterInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List comicDetailChapterInfoResponseDescriptor = $convert.base64Decode('Ch5Db21pY0RldGFpbENoYXB0ZXJJbmZvUmVzcG9uc2USHAoJQ2hhcHRlcklkGAEgASgFUglDaGFwdGVySWQSIgoMQ2hhcHRlclRpdGxlGAIgASgJUgxDaGFwdGVyVGl0bGUSHgoKVXBkYXRldGltZRgDIAEoA1IKVXBkYXRldGltZRIaCghGaWxlc2l6ZRgEIAEoBVIIRmlsZXNpemUSIgoMQ2hhcHRlck9yZGVyGAUgASgFUgxDaGFwdGVyT3JkZXI=');
@$core.Deprecated('Use comicChapterDetailResponseDescriptor instead')
const ComicChapterDetailResponse$json = const {
  '1': 'ComicChapterDetailResponse',
  '2': const [
    const {'1': 'Errno', '3': 1, '4': 1, '5': 5, '9': 0, '10': 'Errno', '17': true},
    const {'1': 'Errmsg', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'Errmsg', '17': true},
    const {'1': 'Data', '3': 3, '4': 1, '5': 11, '6': '.dmzj.comic.ComicChapterDetailInfoResponse', '10': 'Data'},
  ],
  '8': const [
    const {'1': '_Errno'},
    const {'1': '_Errmsg'},
  ],
};

/// Descriptor for `ComicChapterDetailResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List comicChapterDetailResponseDescriptor = $convert.base64Decode('ChpDb21pY0NoYXB0ZXJEZXRhaWxSZXNwb25zZRIZCgVFcnJubxgBIAEoBUgAUgVFcnJub4gBARIbCgZFcnJtc2cYAiABKAlIAVIGRXJybXNniAEBEj4KBERhdGEYAyABKAsyKi5kbXpqLmNvbWljLkNvbWljQ2hhcHRlckRldGFpbEluZm9SZXNwb25zZVIERGF0YUIICgZfRXJybm9CCQoHX0Vycm1zZw==');
@$core.Deprecated('Use comicChapterDetailInfoResponseDescriptor instead')
const ComicChapterDetailInfoResponse$json = const {
  '1': 'ComicChapterDetailInfoResponse',
  '2': const [
    const {'1': 'ChapterId', '3': 1, '4': 1, '5': 5, '10': 'ChapterId'},
    const {'1': 'ComicId', '3': 2, '4': 1, '5': 5, '10': 'ComicId'},
    const {'1': 'Title', '3': 3, '4': 1, '5': 9, '10': 'Title'},
    const {'1': 'Order', '3': 4, '4': 1, '5': 5, '10': 'Order'},
    const {'1': 'Status', '3': 5, '4': 1, '5': 5, '10': 'Status'},
    const {'1': 'SmallPages', '3': 6, '4': 3, '5': 9, '10': 'SmallPages'},
    const {'1': 'Length', '3': 7, '4': 1, '5': 5, '10': 'Length'},
    const {'1': 'RawPages', '3': 8, '4': 3, '5': 9, '10': 'RawPages'},
    const {'1': 'FileSize', '3': 9, '4': 1, '5': 5, '10': 'FileSize'},
  ],
};

/// Descriptor for `ComicChapterDetailInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List comicChapterDetailInfoResponseDescriptor = $convert.base64Decode('Ch5Db21pY0NoYXB0ZXJEZXRhaWxJbmZvUmVzcG9uc2USHAoJQ2hhcHRlcklkGAEgASgFUglDaGFwdGVySWQSGAoHQ29taWNJZBgCIAEoBVIHQ29taWNJZBIUCgVUaXRsZRgDIAEoCVIFVGl0bGUSFAoFT3JkZXIYBCABKAVSBU9yZGVyEhYKBlN0YXR1cxgFIAEoBVIGU3RhdHVzEh4KClNtYWxsUGFnZXMYBiADKAlSClNtYWxsUGFnZXMSFgoGTGVuZ3RoGAcgASgFUgZMZW5ndGgSGgoIUmF3UGFnZXMYCCADKAlSCFJhd1BhZ2VzEhoKCEZpbGVTaXplGAkgASgFUghGaWxlU2l6ZQ==');
