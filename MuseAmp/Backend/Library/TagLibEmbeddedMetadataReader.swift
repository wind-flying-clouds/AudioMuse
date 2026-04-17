import Foundation
import MuseAmpDatabaseKit

enum TagLibEmbeddedMetadataReaderError: Error {
    case unsupportedFormat
}

#if os(tvOS)
final nonisolated class TagLibEmbeddedMetadataReader: @unchecked Sendable {
    func extractArtwork(from _: URL) throws -> Data? {
        throw TagLibEmbeddedMetadataReaderError.unsupportedFormat
    }

    func extractLyrics(from _: URL) throws -> String? {
        throw TagLibEmbeddedMetadataReaderError.unsupportedFormat
    }

    func extractComment(from _: URL) throws -> String? {
        throw TagLibEmbeddedMetadataReaderError.unsupportedFormat
    }

    func makeTrackRecord(
        fileURL _: URL,
        relativePath _: String,
        trackID _: String,
        albumID _: String?,
        fileSize _: Int64,
        modifiedAt _: Date,
    ) throws -> AudioTrackRecord {
        throw TagLibEmbeddedMetadataReaderError.unsupportedFormat
    }
}
#else
final nonisolated class TagLibEmbeddedMetadataReader: @unchecked Sendable {
    func extractArtwork(from fileURL: URL) throws -> Data? {
        let metadata = try loadMetadata(from: fileURL)
        guard let artworkData = metadata.artworkData, !artworkData.isEmpty else {
            return nil
        }
        return artworkData
    }

    func extractLyrics(from fileURL: URL) throws -> String? {
        let metadata = try loadMetadata(from: fileURL)
        let lyrics = metadata.lyrics?.trimmingCharacters(in: .whitespacesAndNewlines)
        return lyrics.nilIfEmpty
    }

    func extractComment(from fileURL: URL) throws -> String? {
        let metadata = try loadMetadata(from: fileURL)
        let comment = metadata.comment?.trimmingCharacters(in: .whitespacesAndNewlines)
        return comment.nilIfEmpty
    }

    func makeTrackRecord(
        fileURL: URL,
        relativePath: String,
        trackID: String,
        albumID: String?,
        fileSize: Int64,
        modifiedAt: Date,
    ) throws -> AudioTrackRecord {
        let metadata = try loadMetadata(from: fileURL)
        let fileName = fileURL.deletingPathExtension().lastPathComponent
        let title = metadata.title?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? fileName
        let artist = metadata.artist?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? String(
            localized: "Unknown Artist",
        )
        let album = metadata.album?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? String(
            localized: "Unknown Album",
        )

        let albumArtist = metadata.albumArtist?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        let genre = metadata.genre?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        let composer = metadata.composer?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        let releaseDate =
            metadata.releaseDate?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
            ?? metadata.year?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty

        let hasEmbeddedLyrics = metadata.lyrics?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty != nil
        let hasEmbeddedArtwork = (metadata.artworkData?.isEmpty == false)

        return AudioTrackRecord(
            trackID: trackID,
            albumID: albumID ?? "unknown",
            fileExtension: fileURL.pathExtension,
            relativePath: relativePath,
            fileSizeBytes: fileSize,
            fileModifiedAt: modifiedAt,
            durationSeconds: max(metadata.duration, 0),
            title: title,
            artistName: artist,
            albumTitle: album,
            albumArtistName: albumArtist,
            trackNumber: metadata.trackNumber > 0 ? metadata.trackNumber : nil,
            discNumber: metadata.discNumber > 0 ? metadata.discNumber : nil,
            genreName: genre,
            composerName: composer,
            releaseDate: releaseDate,
            hasEmbeddedLyrics: hasEmbeddedLyrics,
            hasEmbeddedArtwork: hasEmbeddedArtwork,
            sourceKind: .unknown,
            createdAt: .init(),
            updatedAt: .init(),
        )
    }
}

private nonisolated extension TagLibEmbeddedMetadataReader {
    func loadMetadata(from fileURL: URL) throws -> TagLibAudioMetadata {
        let ext = fileURL.pathExtension.lowercased()
        guard ext == "m4a", TagLibMetadataExtractor.isSupportedFormat(ext) else {
            throw TagLibEmbeddedMetadataReaderError.unsupportedFormat
        }
        return try TagLibMetadataExtractor.extractMetadata(from: fileURL)
    }
}
#endif
